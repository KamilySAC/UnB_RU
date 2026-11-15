require "rails_helper"

RSpec.describe "Login do estudante", type: :request do
  let!(:estudante) do
    Estudante.create!(matricula: "250000001", nome: "Ana Sarah Nagata", password: "senha123")
  end

  describe "POST /login" do
    it "autentica com matrícula e senha e redireciona ao dashboard" do
      post login_path, params: { matricula: "250000001", senha: "senha123" }

      expect(response).to redirect_to(dashboard_path)
      follow_redirect!
      expect(response.body).to include("Ana Sarah Nagata")
    end

    it "recusa senha incorreta" do
      post login_path, params: { matricula: "250000001", senha: "errada" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(SessionsController::MSG_CREDENCIAIS_INVALIDAS)
      get dashboard_path
      expect(response).to redirect_to(login_path)
    end

    it "recusa matrícula não cadastrada" do
      post login_path, params: { matricula: "999999999", senha: "senha123" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(SessionsController::MSG_CREDENCIAIS_INVALIDAS)
    end

    it "recusa conta sem senha cadastrada, mesmo com senha em branco" do
      Estudante.create!(matricula: "250000009", nome: "Sem Senha")

      post login_path, params: { matricula: "250000009", senha: "" }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "cadastro seguido de login" do
    it "permite entrar com a matrícula e a senha informadas no cadastro" do
      post cadastro_path, params: {
        estudante: { matricula: "250000077", nome: "Nova Aluna", senha: "minhasenha", confirmacao_senha: "minhasenha" }
      }
      delete logout_path

      post login_path, params: { matricula: "250000077", senha: "minhasenha" }

      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "DELETE /logout" do
    it "encerra a sessão" do
      post login_path, params: { matricula: "250000001", senha: "senha123" }
      delete logout_path

      expect(response).to redirect_to(login_path)
      get dashboard_path
      expect(response).to redirect_to(login_path)
    end
  end
end
