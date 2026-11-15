require "rails_helper"

RSpec.describe "Painel do funcionário", type: :request do
  let!(:fiscal) do
    Funcionario.create!(nome: "Fulano D.", matricula_siape: "2948102", password: "Senha@123", papel: "fiscal")
  end

  telas = {
    "Configuração de Ponto de Acesso" => :configuracao_ponto_path,
    "Terminal de Validação" => :terminal_validacao_path,
    "Histórico Local" => :historico_local_path
  }

  context "sem funcionário autenticado" do
    telas.each do |titulo, rota|
      it "redireciona #{titulo} para o login" do
        get public_send(rota)

        expect(response).to redirect_to(login_funcionario_path)
      end
    end
  end

  context "com fiscal autenticado" do
    before { post login_funcionario_path, params: { identificador: "2948102", senha: "Senha@123" } }

    telas.each do |titulo, rota|
      it "permite acessar #{titulo}" do
        get public_send(rota)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(titulo)
      end
    end

    it "lista as catracas no Histórico Local com link para o histórico de cada uma" do
      restaurante = Restaurante.create!(codigo: "RU-1", nome: "RU Teste", capacidade_por_hora: 100, total_pisos: 1)
      catraca = restaurante.catracas.create!(codigo: "CAT-01", nome: "Catraca 01", piso: 1, status: :online)

      get historico_local_path

      expect(response.body).to include("Catraca 01", catraca_acessos_path(catraca))
    end
  end
end