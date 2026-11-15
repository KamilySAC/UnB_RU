require "rails_helper"

RSpec.describe "Cardápio na página inicial do estudante", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:arquivo) { Rails.root.join("tmp", "cardapio_request_spec.json") }
  let(:cardapio_json) do
    {
      "segunda-feira" => {
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
        }
      }
    }
  end

  before do
    Estudante.create!(matricula: "250000010", nome: "Ana Sarah Nagata", password: "senha123")
    Restaurante.create!(codigo: "RU-01", nome: "RU Darcy Ribeiro", total_pisos: 1)
    File.write(arquivo, cardapio_json.to_json)
    CardapioAtual.arquivo = arquivo
    post login_path, params: { matricula: "250000010", senha: "senha123" }
  end

  after do
    CardapioAtual.arquivo = nil
    FileUtils.rm_f(arquivo)
  end

  context "quando há cardápio para a refeição atual" do
    it "mostra restaurante, horário e as três opções com todos os itens" do
      travel_to Time.find_zone!("Brasilia").local(2026, 11, 16, 12, 0) do
        get dashboard_path
      end

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("RU Darcy Ribeiro", "11:00 às 14:30")
      expect(response.body).to include("Padrão", "Ovolactovegetariano", "Vegetariano estrito")
      expect(response.body).to include("Prato principal", "Guarnição", "Salada", "Sobremesa", "Bebida")
      expect(response.body).to include("Frango assado com manjericão", "Quiche de legumes", "Refogado de lentilha")
    end

    it "aparece ao acessar a raiz, que redireciona o estudante logado para a página inicial" do
      travel_to Time.find_zone!("Brasilia").local(2026, 11, 16, 12, 0) do
        get root_path
        follow_redirect!
      end

      expect(response.body).to include("Cardápio da refeição atual", "Frango assado com manjericão")
    end
  end

  context "quando não há cardápio para a refeição atual" do
    it "informa a indisponibilidade fora do horário de funcionamento" do
      travel_to Time.find_zone!("Brasilia").local(2026, 11, 16, 3, 0) do
        get dashboard_path
      end

      expect(response.body).to include(CardapioAtual::MSG_INDISPONIVEL)
      expect(response.body).not_to include("Frango assado com manjericão")
    end

    it "informa a indisponibilidade quando o dia não tem cardápio" do
      travel_to Time.find_zone!("Brasilia").local(2026, 11, 17, 12, 0) do
        get dashboard_path
      end

      expect(response.body).to include(CardapioAtual::MSG_INDISPONIVEL)
    end
  end

  it "não exibe o cardápio para quem não está logado" do
    delete logout_path

    get dashboard_path

    expect(response).to redirect_to(login_path)
  end
end