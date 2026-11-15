require "rails_helper"

RSpec.describe "Login do funcionário", type: :request do
  let!(:fiscal) do
    Funcionario.create!(nome: "Fulano D.", matricula_siape: "2948102", usuario: "fulano.fiscal",
                        password: "Senha@123", papel: "fiscal")
  end

  describe "GET /funcionario/login" do
    it "exibe a tela Autenticação do Operador com a senha oculta" do
      get login_funcionario_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Autenticação do Operador", "Entrar no Sistema")
      expect(response.body).to include('type="password"', 'id="alternar-senha"')
    end
  end

  describe "POST /funcionario/login" do
    it "autentica por matrícula SIAPE e mostra nome e matrícula" do
      post login_funcionario_path, params: { identificador: "2948102", senha: "Senha@123" }

      expect(response).to redirect_to(configuracao_ponto_path)
      follow_redirect!
      expect(response.body).to include("Configuração de Ponto de Acesso", "Fulano D.", "2948102")
    end

    it "autentica por usuário" do
      post login_funcionario_path, params: { identificador: "fulano.fiscal", senha: "Senha@123" }

      expect(response).to redirect_to(configuracao_ponto_path)
    end

    it "recusa senha incorreta e identificador inexistente com a mesma mensagem" do
      post login_funcionario_path, params: { identificador: "2948102", senha: "SenhaErrada" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Credenciais inválidas")

      post login_funcionario_path, params: { identificador: "0000000", senha: "Senha@123" }
      expect(response.body).to include("Credenciais inválidas")
    end

    it "informa que a matrícula ou usuário é obrigatório" do
      post login_funcionario_path, params: { identificador: "", senha: "Senha@123" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("A matrícula ou usuário é obrigatório.")
      expect(response.body).not_to include("A senha é obrigatória.")
    end

    it "informa que a senha é obrigatória" do
      post login_funcionario_path, params: { identificador: "2948102", senha: "" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("A senha é obrigatória.")
    end
  end

  describe "DELETE /funcionario/logout" do
    it "encerra a sessão e volta para o login" do
      post login_funcionario_path, params: { identificador: "2948102", senha: "Senha@123" }

      delete logout_funcionario_path

      expect(response).to redirect_to(login_funcionario_path)
      get configuracao_ponto_path
      expect(response).to redirect_to(login_funcionario_path)
    end
  end
end