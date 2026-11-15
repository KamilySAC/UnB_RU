# Cardápio da refeição que está sendo servida agora.
# Lê o cardapio.json (dia da semana -> turno -> pratos), descobre o turno em andamento
# pelo horário de Brasília e monta as 3 opções: padrão, ovolactovegetariano e vegetariano estrito.
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

  # true quando existe cardápio para o dia e o turno em andamento
  def disponivel?
    dados_do_turno.present?
  end

  def turno_nome
    TURNOS.dig(turno_atual, :nome)
  end

  # ex.: "11:00 às 14:30"
  def horario
    turno = TURNOS[turno_atual]
    "#{turno[:inicio]} às #{turno[:fim]}" if turno
  end

  def restaurante_nome
    Restaurante.order(:nome).first&.nome || NOME_RESTAURANTE_PADRAO
  end

  def opcoes
    return [] unless disponivel?

    OPCOES.map { |chave, nome| montar_opcao(chave, nome) }
  end

  # arroz, feijão etc.: comum às três opções (não existe no café da manhã)
  def acompanhamentos
    Array(dados_do_turno && dados_do_turno["acompanhamentos"]).join(" e ").presence
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

  def dados_do_turno
    return @dados_do_turno if defined?(@dados_do_turno)

    dados = turno_atual && cardapio_completo.dig(DIAS[agora.wday], turno_atual)
    @dados_do_turno = dados.is_a?(Hash) ? dados : nil
  end

  # arquivo ausente ou inválido equivale a "sem cardápio cadastrado"
  def cardapio_completo
    conteudo = JSON.parse(File.read(self.class.arquivo))
    conteudo.is_a?(Hash) ? conteudo : {}
  rescue Errno::ENOENT, JSON::ParserError
    {}
  end

  def montar_opcao(chave, nome)
    if turno_atual == "cafe_da_manha"
      opcao_do_cafe(chave, nome)
    else
      opcao_de_refeicao(chave, nome)
    end
  end

  def opcao_de_refeicao(chave, nome)
    dados = dados_do_turno
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
  def opcao_do_cafe(chave, nome)
    dados = dados_do_turno
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