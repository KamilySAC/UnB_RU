require "rails_helper"

RSpec.describe CardapioAtual do
  let(:cardapio_json) do
    {
      "segunda-feira" => {
        "cafe_da_manha" => {
          "bebidas" => [ "Leite integral ou Bebida de soja", "Café OU chá" ],
          "panificacao" => [ "Pão francês", "Pão integral" ],
          "opcao_extra" => "Pão de queijo",
          "gordura" => "Manteiga ou creme vegetal",
          "complemento_padrao" => "Carne desfiada",
          "complemento_ovolactovegetariano" => "Queijo muçarela",
          "complemento_vegetariano_estrito" => "Homus de grão de bico",
          "fruta" => "Abacaxi"
        },
        "almoco" => {
          "salada_1" => "Alface lisa com agrião",
          "salada_2" => "Tomate",
          "prato_principal_padrao" => "Frango assado com manjericão",
          "prato_principal_ovolactovegetariano" => "Quiche de legumes",
          "prato_principal_vegetariano_estrito" => "Refogado de lentilha",
          "guarnicao" => "Jardineira verde",
          "acompanhamentos" => [ "Arroz branco e integral", "Feijão preto" ],
          "sobremesa" => "Mix de doces",
          "bebida" => "Refresco de morango"
        },
        "jantar" => {
          "salada_1" => "Mix de folhas",
          "salada_2" => "Beterraba ralada",
          "prato_principal_padrao" => "Lagarto ao molho escuro",
          "prato_principal_ovolactovegetariano" => "Ovos mexidos com castanhas",
          "prato_principal_vegetariano_estrito" => "Tomate recheado com soja",
          "sopa" => "Creme de abóbora",
          "torrada" => "Torrada",
          "acompanhamentos" => [ "Arroz branco e integral", "Feijão preto" ],
          "sobremesa" => "Laranja",
          "bebida" => "Refresco de morango"
        }
      }
    }
  end

  let(:arquivo) { Rails.root.join("tmp", "cardapio_spec.json") }

  # 16/11/2026 é uma segunda-feira
  def em(hora, minuto = 0, dia: 16)
    Time.find_zone!("Brasilia").local(2026, 11, dia, hora, minuto)
  end

  before do
    File.write(arquivo, cardapio_json.to_json)
    described_class.arquivo = arquivo
  end

  after do
    described_class.arquivo = nil
    FileUtils.rm_f(arquivo)
  end

  describe "refeição atual disponível" do
    subject(:cardapio) { described_class.new(agora: em(12, 0)) }

    it "reconhece o almoço e informa o horário de funcionamento" do
      expect(cardapio).to be_disponivel
      expect(cardapio.turno_nome).to eq("Almoço")
      expect(cardapio.horario).to eq("11:00 às 14:30")
    end

    it "apresenta as três opções, na ordem padrão, ovolactovegetariano e vegetariano estrito" do
      expect(cardapio.opcoes.map(&:nome)).to eq([ "Padrão", "Ovolactovegetariano", "Vegetariano estrito" ])
    end

    it "apresenta prato principal, guarnição, salada, sobremesa e bebida em cada opção" do
      padrao = cardapio.opcoes.first

      expect(padrao.prato_principal).to eq("Frango assado com manjericão")
      expect(padrao.guarnicao).to eq("Jardineira verde")
      expect(padrao.salada).to eq("Alface lisa com agrião e Tomate")
      expect(padrao.sobremesa).to eq("Mix de doces")
      expect(padrao.bebida).to eq("Refresco de morango")
    end

    it "troca apenas o prato principal entre as opções" do
      expect(cardapio.opcoes.map(&:prato_principal)).to eq(
        [ "Frango assado com manjericão", "Quiche de legumes", "Refogado de lentilha" ]
      )
      expect(cardapio.opcoes.map(&:sobremesa).uniq).to eq([ "Mix de doces" ])
    end

    it "lista os acompanhamentos comuns às opções" do
      expect(cardapio.acompanhamentos).to eq("Arroz branco e integral e Feijão preto")
    end
  end

  describe "limites dos turnos" do
    it "inclui o horário de início e exclui o de término" do
      expect(described_class.new(agora: em(11, 0))).to be_disponivel
      expect(described_class.new(agora: em(14, 29))).to be_disponivel
      expect(described_class.new(agora: em(14, 30))).not_to be_disponivel
    end
  end

  describe "jantar" do
    subject(:cardapio) { described_class.new(agora: em(18, 0)) }

    it "usa sopa e torrada como guarnição" do
      expect(cardapio.turno_nome).to eq("Jantar")
      expect(cardapio.opcoes.first.guarnicao).to eq("Creme de abóbora e Torrada")
    end
  end

  describe "café da manhã" do
    subject(:cardapio) { described_class.new(agora: em(8, 0)) }

    it "usa o complemento como prato principal e a fruta como sobremesa" do
      vegetariana = cardapio.opcoes.last

      expect(cardapio.turno_nome).to eq("Café da manhã")
      expect(vegetariana.prato_principal).to eq("Homus de grão de bico")
      expect(vegetariana.guarnicao).to eq("Pão francês, Pão integral com Manteiga ou creme vegetal e Pão de queijo")
      expect(vegetariana.sobremesa).to eq("Abacaxi")
      expect(vegetariana.bebida).to eq("Leite integral ou Bebida de soja e Café OU chá")
    end

    it "não tem salada" do
      expect(cardapio.opcoes.map(&:salada)).to all(be_nil)
    end
  end

  describe "fuso horário" do
    it "usa o horário de Brasília, mesmo recebendo o horário em UTC" do
      # 14:00 UTC = 11:00 em Brasília (segunda-feira)
      cardapio = described_class.new(agora: Time.utc(2026, 11, 16, 14, 0))

      expect(cardapio.turno_nome).to eq("Almoço")
    end
  end

  describe "cardápio indisponível" do
    it "fora do horário de funcionamento de qualquer turno" do
      cardapio = described_class.new(agora: em(3, 0))

      expect(cardapio).not_to be_disponivel
      expect(cardapio.opcoes).to eq([])
      expect(cardapio.horario).to be_nil
    end

    it "quando não há cardápio cadastrado para o dia" do
      cardapio = described_class.new(agora: em(12, 0, dia: 17))

      expect(cardapio).not_to be_disponivel
      expect(cardapio.opcoes).to eq([])
    end

    it "quando o arquivo não existe" do
      described_class.arquivo = Rails.root.join("tmp", "nao_existe.json")

      expect(described_class.new(agora: em(12, 0))).not_to be_disponivel
    end

    it "quando o arquivo está corrompido" do
      File.write(arquivo, "{ isto nao e json")

      expect(described_class.new(agora: em(12, 0))).not_to be_disponivel
    end
  end

  describe "#restaurante_nome" do
    it "usa o primeiro restaurante cadastrado" do
      Restaurante.create!(codigo: "RU-01", nome: "RU Darcy Ribeiro", total_pisos: 1)

      expect(described_class.new(agora: em(12, 0)).restaurante_nome).to eq("RU Darcy Ribeiro")
    end

    it "usa o nome padrão quando não há restaurante cadastrado" do
      expect(described_class.new(agora: em(12, 0)).restaurante_nome).to eq(CardapioAtual::NOME_RESTAURANTE_PADRAO)
    end
  end
end