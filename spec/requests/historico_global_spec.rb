require "rails_helper"

RSpec.describe "Histórico global de acessos", type: :request do
  let!(:admin) do
    Funcionario.create!(nome: "Admin Demo", matricula_siape: "1234567", password: "Admin@1234", papel: "administrador")
  end
  let!(:fiscal) do
    Funcionario.create!(nome: "Fulano D.", matricula_siape: "2948102", password: "Senha@123", papel: "fiscal")
  end

  let!(:ru1) { Restaurante.create!(codigo: "RU-1", nome: "Restaurante 1", capacidade_por_hora: 100, total_pisos: 2) }
  let!(:ru2) { Restaurante.create!(codigo: "RU-2", nome: "Restaurante 2", capacidade_por_hora: 100, total_pisos: 2) }
  let!(:cat04) { ru1.catracas.create!(codigo: "CAT-04", nome: "Catraca 04", piso: 1, status: :online) }
  let!(:cat02) { ru2.catracas.create!(codigo: "CAT-02", nome: "Catraca 02", piso: 1, status: :online) }
  let!(:cat05) { ru2.catracas.create!(codigo: "CAT-05", nome: "Catraca 05", piso: 1, status: :online) }

  def criar_acesso(catraca, **atributos)
    catraca.acessos.create!({
                              matricula_discente: "MAT-TESTE",
                              turno: "Almoço",
                              modo_validacao: "Cartão",
                              tarifa: 2.50,
                              status_acesso: :liberado,
                              status_catraca: :online,
                              ocorrido_em: Time.current
                            }.merge(atributos))
  end

  def entrar(identificador, senha)
    post login_funcionario_path, params: { identificador: identificador, senha: senha }
  end

  before do
    criar_acesso(cat04, matricula_discente: "MAT-R1", tarifa: 2.50)
    criar_acesso(cat02, matricula_discente: "MAT-R2", tarifa: 4.50)
  end

  context "sem funcionário autenticado" do
    it "redireciona para o login" do
      get historico_global_path

      expect(response).to redirect_to(login_funcionario_path)
    end
  end

  context "com fiscal autenticado" do
    before { entrar("2948102", "Senha@123") }

    it "não mostra o histórico global e leva ao histórico local" do
      get historico_global_path

      expect(response).to redirect_to(historico_local_path)
      follow_redirect!
      expect(response.body).to include("Histórico Local", "Você não tem permissão")
      expect(response.body).not_to include("MAT-R1", "MAT-R2")
    end

    it "não mostra o link do histórico global no menu" do
      get historico_local_path

      expect(response.body).not_to include("Histórico Global")
    end
  end

  context "com administrador autenticado" do
    before { entrar("1234567", "Admin@1234") }

    it "mostra o link no menu" do
      get historico_local_path

      expect(response.body).to include("Histórico Global", historico_global_path)
    end

    it "lista os acessos de todos os restaurantes e catracas com os dados de cada um" do
      get historico_global_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("MAT-R1", "MAT-R2", "Restaurante 1", "Restaurante 2", "Catraca 04", "Catraca 02")
      expect(response.body).to include("Horário", "Matrícula", "Tarifa", "Status da catraca")
    end

    it "mostra o total de acessos e a arrecadação bruta do campus" do
      get historico_global_path

      expect(response.body).to include('id="total-acessos">2<', "R$ 7,00")
    end

    it "mostra acessos bloqueados com tarifa R$ 0,00 e o motivo, mesmo com tarifa gravada" do
      criar_acesso(cat04, matricula_discente: "MAT-BLOQ", tarifa: 2.50,
                   status_acesso: :bloqueado, motivo_negativa: "Saldo Insuficiente")

      get historico_global_path

      linha = response.body[/<tr>(?:(?!<\/tr>).)*MAT-BLOQ(?:(?!<\/tr>).)*<\/tr>/m]
      expect(linha).to include("R$ 0,00", "Saldo Insuficiente")
      # bloqueado não entra na arrecadação
      expect(response.body).to include("R$ 7,00")
    end

    it "filtra por restaurante" do
      get historico_global_path, params: { restaurante_id: ru1.id }

      expect(response.body).to include("MAT-R1")
      expect(response.body).not_to include("MAT-R2")
    end

    it "filtra por catraca específica" do
      get historico_global_path, params: { restaurante_id: ru2.id, catraca_id: cat02.id }

      expect(response.body).to include("MAT-R2")
      expect(response.body).not_to include("MAT-R1")
    end

    it "só oferece como opção as catracas do restaurante selecionado" do
      get historico_global_path, params: { restaurante_id: ru2.id }

      opcoes = response.body[/<select[^>]*id="catraca_id".*?<\/select>/m]
      expect(opcoes).to include("Catraca 02", "Catraca 05")
      expect(opcoes).not_to include("Catraca 04")
    end

    it "ignora a catraca que não pertence ao restaurante selecionado" do
      get historico_global_path, params: { restaurante_id: ru2.id, catraca_id: cat04.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("MAT-R2")
      expect(response.body).not_to include("MAT-R1")
    end

    it "agrupa por restaurante com acessos, pontualidade, arrecadação e total consolidado" do
      get historico_global_path, params: { agrupar: "restaurante" }

      expect(response.body).to include("agrupado-restaurante", "Pontualidade", "Arrecadação bruta", "Total consolidado")
      expect(response.body).to include("Restaurante 1", "Restaurante 2", "100,0%", "R$ 2,50", "R$ 4,50")
      expect(response.body).not_to include("MAT-R1")
    end

    it "agrupa por catraca com passagens e total debitado" do
      get historico_global_path, params: { agrupar: "catraca" }

      expect(response.body).to include("agrupado-catraca", "Passagens", "Total debitado")
      expect(response.body).to include("Restaurante 1 - Catraca 04", "Restaurante 2 - Catraca 05")
    end

    it "informa que não há acessos para a catraca sem registros" do
      get historico_global_path, params: { catraca_id: cat05.id }

      expect(response.body).to include("Não há acessos para os filtros selecionados.")
      expect(response.body).not_to include("MAT-R1", "MAT-R2")
    end

    it "retorna bad request para filtro inexistente ou agrupamento desconhecido" do
      get historico_global_path, params: { restaurante_id: 0 }
      expect(response).to have_http_status(:bad_request)

      get historico_global_path, params: { catraca_id: "abc" }
      expect(response).to have_http_status(:bad_request)

      get historico_global_path, params: { agrupar: "turno" }
      expect(response).to have_http_status(:bad_request)
    end
  end
end