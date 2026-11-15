require "rails_helper"

RSpec.describe "Cadastro de estudante", type: :request do
  let(:parametros) do
    { estudante: { matricula: "250000001", nome: "Ana Sarah Nagata", senha: "senha123", confirmacao_senha: "senha123" } }
  end

  describe "GET /cadastro" do
    it "exibe o formulário com matrícula, nome completo, senha e confirmação" do
      get cadastro_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Matrícula", "Nome completo", "Senha", "Confirmação de senha")
      expect(response.body).to include('type="password"')
    end
  end

  describe "POST /cadastro" do
    context "com informações válidas" do
      it "cria a conta, inicia a sessão e redireciona para a página inicial com mensagem de confirmação" do
        expect { post cadastro_path, params: parametros }.to change(Estudante, :count).by(1)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include(CadastroEstudante::MSG_SUCESSO)
        expect(response.body).to include("Ana Sarah Nagata")
      end
    end

    context "com senhas diferentes" do
      it "não cria a conta e informa que as senhas não são iguais" do
        parametros[:estudante][:confirmacao_senha] = "diferente"

        expect { post cadastro_path, params: parametros }.not_to change(Estudante, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("As senhas não são iguais")
      end
    end

    context "com campo obrigatório vazio" do
      it "não cria a conta e informa que todos os campos devem ser preenchidos" do
        parametros[:estudante][:nome] = ""

        expect { post cadastro_path, params: parametros }.not_to change(Estudante, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Todos os campos devem ser preenchidos")
      end

      it "trata a ausência total de parâmetros como campos vazios, sem erro 500" do
        expect { post cadastro_path }.not_to change(Estudante, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Todos os campos devem ser preenchidos")
      end
    end

    context "com matrícula já cadastrada" do
      before { Estudante.create!(nome: "Aluno Existente", matricula: "250000001") }

      it "não cria a conta e informa que a matrícula já foi cadastrada" do
        expect { post cadastro_path, params: parametros }.not_to change(Estudante, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Matrícula já cadastrada")
      end
    end

    context "quando o cadastro falha" do
      it "mantém matrícula e nome digitados, mas nunca devolve a senha na tela" do
        parametros[:estudante][:confirmacao_senha] = "diferente"

        post cadastro_path, params: parametros

        expect(response.body).to include('value="250000001"')
        expect(response.body).to include('value="Ana Sarah Nagata"')
        expect(response.body).not_to include("senha123")
      end
    end
  end
end
