# consulta do histórico global de acessos do campus (visão do administrador)
# aplica os filtros (restaurante e catraca) e calcula totais e agrupamentos
class HistoricoGlobal
  # motivo que conta como acesso fora do horário (usado na pontualidade)
  MOTIVO_JANELA_EXPIRADA = "Janela Expirada".freeze

  AGRUPAMENTOS = %w[restaurante catraca].freeze

  # uma linha das tabelas agrupadas
  #   acessos: todas as tentativas; passagens: só as liberadas
  #   arrecadacao: soma da tarifa das passagens liberadas
  #   pontualidade: % de acessos que NÃO foram bloqueados por janela expirada (nil se não há acessos)
  Linha = Struct.new(:nome, :acessos, :passagens, :arrecadacao, :pontualidade, keyword_init: true)

  attr_reader :restaurante, :catraca, :agrupar

  def initialize(restaurante: nil, catraca: nil, agrupar: nil)
    @restaurante = restaurante
    # catraca de outro restaurante não vale como filtro (não aparece nas opções)
    @catraca = catraca if catraca.nil? || restaurante.nil? || catraca.restaurante_id == restaurante.id
    @agrupar = agrupar.to_s if AGRUPAMENTOS.include?(agrupar.to_s)
  end

  # acessos da listagem, do mais recente para o mais antigo
  def acessos
    escopo.includes(catraca: :restaurante).order(ocorrido_em: :desc)
  end

  def total_acessos
    totais.acessos
  end

  def arrecadacao_bruta
    totais.arrecadacao
  end

  def sem_acessos?
    total_acessos.zero?
  end

  # totais do campus considerando os filtros aplicados
  def totais
    @totais ||= linha_de("Total consolidado", *escopo.pick(*EXPRESSOES.values))
  end

  def restaurantes_disponiveis
    Restaurante.order(:nome)
  end

  # com restaurante selecionado, só as catracas dele ficam como opção
  def catracas_disponiveis
    base = restaurante ? restaurante.catracas : Catraca.all
    base.includes(:restaurante).order(:nome)
  end

  def linhas_por_restaurante
    dados = agregar("catracas.restaurante_id")
    restaurantes_no_escopo.map do |r|
      linha_de(r.nome, *dados.fetch(r.id, []))
    end
  end

  def linhas_por_catraca
    dados = agregar("acessos.catraca_id")
    catracas_no_escopo.map do |c|
      linha_de("#{c.restaurante.nome} - #{c.nome}", *dados.fetch(c.id, []))
    end
  end

  private

  LIBERADO = Acesso.status_acessos.fetch("liberado")

  # expressões SQL fixas (sem dado do usuário): total, passagens, arrecadação e acessos fora da janela
  EXPRESSOES = {
    acessos: "COUNT(*)",
    passagens: "SUM(CASE WHEN acessos.status_acesso = #{LIBERADO} THEN 1 ELSE 0 END)",
    arrecadacao: "SUM(CASE WHEN acessos.status_acesso = #{LIBERADO} THEN acessos.tarifa ELSE 0 END)",
    janela_expirada: "SUM(CASE WHEN LOWER(acessos.motivo_negativa) = '#{MOTIVO_JANELA_EXPIRADA.downcase}' THEN 1 ELSE 0 END)"
  }.transform_values { |sql| Arel.sql(sql) }.freeze

  def escopo
    relacao = Acesso.joins(:catraca)
    relacao = relacao.where(catracas: { restaurante_id: restaurante.id }) if restaurante
    relacao = relacao.where(catraca_id: catraca.id) if catraca
    relacao
  end

  # { id do grupo => [acessos, passagens, arrecadação, janela expirada] }
  def agregar(coluna)
    escopo.group(Arel.sql(coluna)).pluck(Arel.sql(coluna), *EXPRESSOES.values).to_h do |id, *valores|
      [ id, valores ]
    end
  end

  def restaurantes_no_escopo
    return [ catraca.restaurante ] if catraca
    return [ restaurante ] if restaurante

    Restaurante.order(:nome)
  end

  def catracas_no_escopo
    return [ catraca ] if catraca

    catracas_disponiveis
  end

  def linha_de(nome, acessos = 0, passagens = 0, arrecadacao = 0, janela_expirada = 0)
    acessos = acessos.to_i
    Linha.new(
      nome: nome,
      acessos: acessos,
      passagens: passagens.to_i,
      arrecadacao: (arrecadacao || 0).to_d.round(2),
      pontualidade: acessos.zero? ? nil : (((acessos - janela_expirada.to_i) * 100.0) / acessos).round(1)
    )
  end
end