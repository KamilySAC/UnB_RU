# Cardápio do dia, com as três refeições (café da manhã, almoço e jantar).
# Lê o cardapio.json (dia da semana -> turno -> pratos), descobre o turno em andamento
# pelo horário de Brasília e monta, para cada refeição, as 3 opções: padrão, ovolactovegetariano
# e vegetariano estrito. A refeição em andamento é marcada como "atual" para a tela abri-la.
class CardapioAtual
  MSG_INDISPONIVEL = "Cardápio indisponível para a refeição atual.".freeze

  FUSO = "Brasilia".freeze
  NOME_RESTAURANTE_PADRAO = "RU Darcy Ribeiro".freeze

  # chave usada no wday do Ruby (0 = domingo) -> chave usada no cardapio.json
  DIAS = %w[domingo segunda-feira terca-feira quarta-feira quinta-feira sexta-feira sabado].freeze

  # horário de funcionamento de cada turno (início inclusive, fim exclusive)
  TURNOS = {
    "cafe_da_manha" => { nome: "Café da manhã", inicio: "07:00", fim: "09:00" },
    "almoco" => { nome: "Almoço", inicio: "11:00", fim: "14:30" },
    "jantar" => { nome: "Jantar", inicio: "17:30", fim: "19:30" }
  }.freeze

  # chave da opção no cardapio.json -> nome exibido
  OPCOES = {
    "padrao" => "Padrão",
    "ovolactovegetariano" => "Ovolactovegetariano",
    "vegetariano_estrito" => "Vegetariano estrito"
  }.freeze

  ARQUIVO_PADRAO = Rails.root.join("cardapio.json")

  # uma opção de cardápio pronta para exibir; campos sem valor ficam nil
  Opcao = Struct.new(:nome, :prato_principal, :guarnicao, :salada, :sobremesa, :bebida, keyword_init: true)

  # uma refeição do dia (café, almoço ou jantar) pronta para exibir
  Turno = Struct.new(:chave, :nome, :horario, :atual, :opcoes, :acompanhamentos, keyword_init: true) do
    # true quando existe cardápio cadastrado para essa refeição
    def disponivel?
      opcoes.any?
    end

    def atual?
      atual
    end
  end

  class << self
    # permite trocar o arquivo (usado nos testes)
    attr_writer :arquivo

    def arquivo
      @arquivo || ARQUIVO_PADRAO
    end
  end

  attr_reader :agora

  def initialize(agora: Time.current)
    @agora = agora.in_time_zone(FUSO)
  end

  # as três refeições do dia, na ordem café, almoço e jantar (a em andamento vem com atual? true)
  def turnos
    @turnos ||= TURNOS.map do |chave, turno|
      Turno.new(
        chave: chave,
        nome: turno[:nome],
        horario: horario_de(turno),
        atual: chave == turno_atual,
        opcoes: opcoes_de(chave),
        acompanhamentos: acompanhamentos_de(chave)
      )
    end
  end

  # true quando existe cardápio para o dia e o turno em andamento
  def disponivel?
    dados_do_turno(turno_atual).present?
  end

  def turno_nome
    TURNOS.dig(turno_atual, :nome)
  end

  # ex.: "11:00 às 14:30"
  def horario
    turno = TURNOS[turno_atual]
    horario_de(turno) if turno
  end

  def restaurante_nome
    Restaurante.order(:nome).first&.nome || NOME_RESTAURANTE_PADRAO
  end

  # opções da refeição em andamento
  def opcoes
    opcoes_de(turno_atual)
  end

  # arroz, feijão etc.: comum às três opções (não existe no café da manhã)
  def acompanhamentos
    acompanhamentos_de(turno_atual)
  end

  private

  # chave do turno em andamento no horário de Brasília (nil fora do funcionamento)
  def turno_atual
    minutos = (agora.hour * 60) + agora.min
    TURNOS.find { |_, turno| minutos >= minutos_de(turno[:inicio]) && minutos < minutos_de(turno[:fim]) }&.first
  end

  def minutos_de(hora)
    horas, minutos = hora.split(":").map(&:to_i)
    (horas * 60) + minutos
  end

  def horario_de(turno)
    "#{turno[:inicio]} às #{turno[:fim]}"
  end

  # dados do dia para um turno (nil se não houver); cada turno é lido uma vez por instância
  def dados_do_turno(chave)
    @dados_dos_turnos ||= {}
    return @dados_dos_turnos[chave] if @dados_dos_turnos.key?(chave)

    dados = chave && cardapio_completo.dig(DIAS[agora.wday], chave)
    @dados_dos_turnos[chave] = dados.is_a?(Hash) ? dados : nil
  end

  # arquivo ausente ou inválido equivale a "sem cardápio cadastrado"
  def cardapio_completo
    @cardapio_completo ||= begin
      conteudo = JSON.parse(File.read(self.class.arquivo))
      conteudo.is_a?(Hash) ? conteudo : {}
    rescue Errno::ENOENT, JSON::ParserError
      {}
    end
  end

  def opcoes_de(turno)
    return [] if dados_do_turno(turno).blank?

    OPCOES.map { |chave, nome| montar_opcao(turno, chave, nome) }
  end

  def acompanhamentos_de(turno)
    dados = dados_do_turno(turno)
    Array(dados && dados["acompanhamentos"]).join(" e ").presence
  end

  def montar_opcao(turno, chave, nome)
    dados = dados_do_turno(turno)

    if turno == "cafe_da_manha"
      opcao_do_cafe(dados, chave, nome)
    else
      opcao_de_refeicao(dados, chave, nome)
    end
  end

  def opcao_de_refeicao(dados, chave, nome)
    Opcao.new(
      nome: nome,
      prato_principal: dados["prato_principal_#{chave}"],
      guarnicao: dados["guarnicao"] || juntar([ dados["sopa"], dados["torrada"] ]),
      salada: juntar([ dados["salada_1"], dados["salada_2"] ]),
      sobremesa: dados["sobremesa"],
      bebida: dados["bebida"]
    )
  end

  # o café não tem prato principal nem salada: o complemento do pão faz o papel de prato principal
  def opcao_do_cafe(dados, chave, nome)
    paes = juntar(Array(dados["panificacao"]), ", ")
    guarnicao = [ paes, dados["gordura"] ].compact_blank.join(" com ")

    Opcao.new(
      nome: nome,
      prato_principal: dados["complemento_#{chave}"],
      guarnicao: juntar([ guarnicao, dados["opcao_extra"] ]),
      salada: nil,
      sobremesa: dados["fruta"],
      bebida: juntar(Array(dados["bebidas"]))
    )
  end

  def juntar(itens, separador = " e ")
    itens.compact_blank.join(separador).presence
  end
end
