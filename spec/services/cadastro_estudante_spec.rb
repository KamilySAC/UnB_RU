require "rails_helper"

RSpec.describe CadastroEstudante do
  let(:dados_validos) do
    { matricula: "250000001", nome: "José da Silva", senha: "senha123", confirmacao_senha: "senha123" }
  end

  def cadastrar(**alteracoes)
    cadastro = described_class.new(**dados_validos.merge(alteracoes))
    cadastro.call
    cadastro
  end

  describe "cadastro com informações válidas (caminho feliz)" do
    it "cria a conta do estudante" do
      expect { cadastrar }.to change(Estudante, :count).by(1)
    end

    it "retorna sucesso, sem erros, e expõe o estudante criado" do
      cadastro = cadastrar

      expect(cadastro).to be_sucesso
      expect(cadastro.erros).to be_empty
      expect(cadastro.estudante).to be_persisted
      expect(cadastro.estudante.matricula).to eq("250000001")
      expect(cadastro.estudante.nome).to eq("José da Silva")
    end

    it "guarda a senha criptografada e permite autenticar com ela" do
      estudante = cadastrar.estudante

      expect(estudante.password_digest).to be_present
      expect(estudante.password_digest).not_to include("senha123")
      expect(estudante.authenticate("senha123")).to eq(estudante)
      expect(estudante.authenticate("senha-errada")).to be false
    end

    it "remove espaços em volta da matrícula e do nome" do
      estudante = cadastrar(matricula: "  250000001 ", nome: "  José da Silva  ").estudante

      expect(estudante.matricula).to eq("250000001")
      expect(estudante.nome).to eq("José da Silva")
    end

    it "usa o grupo tarifário e o saldo padrão do banco" do
      estudante = cadastrar.estudante

      expect(estudante.grupo).to eq("Grupo II")
      expect(estudante.saldo).to eq(0)
    end
  end

  describe "campos obrigatórios (caminho triste)" do
    %i[matricula nome senha confirmacao_senha].each do |campo|
      context "quando #{campo} está vazio" do
        it "não cria a conta e informa que todos os campos devem ser preenchidos" do
          cadastro = nil

          expect { cadastro = cadastrar(campo => "") }.not_to change(Estudante, :count)
          expect(cadastro).not_to be_sucesso
          expect(cadastro.erros).to eq([ CadastroEstudante::MSG_CAMPOS_OBRIGATORIOS ])
        end
      end
    end

    it "trata campo só com espaços como vazio" do
      cadastro = cadastrar(nome: "   ")

      expect(cadastro.erros).to eq([ CadastroEstudante::MSG_CAMPOS_OBRIGATORIOS ])
      expect(Estudante.count).to eq(0)
    end

    it "trata campo nil como vazio" do
      cadastro = cadastrar(matricula: nil)

      expect(cadastro.erros).to eq([ CadastroEstudante::MSG_CAMPOS_OBRIGATORIOS ])
    end
  end

  describe "senha e confirmação diferentes (caminho triste)" do
    it "não cria a conta e informa que as senhas não são iguais" do
      cadastro = nil

      expect { cadastro = cadastrar(confirmacao_senha: "outra-senha") }.not_to change(Estudante, :count)
      expect(cadastro).not_to be_sucesso
      expect(cadastro.erros).to eq([ CadastroEstudante::MSG_SENHAS_DIFERENTES ])
    end

    it "diferencia maiúsculas de minúsculas" do
      cadastro = cadastrar(confirmacao_senha: "SENHA123")

      expect(cadastro.erros).to include(CadastroEstudante::MSG_SENHAS_DIFERENTES)
    end
  end

  describe "matrícula já cadastrada (caminho triste)" do
    before { Estudante.create!(nome: "Aluno Existente", matricula: "250000001") }

    it "não cria uma segunda conta e informa que a matrícula já foi cadastrada" do
      cadastro = nil

      expect { cadastro = cadastrar }.not_to change(Estudante, :count)
      expect(cadastro).not_to be_sucesso
      expect(cadastro.erros).to eq([ CadastroEstudante::MSG_MATRICULA_EXISTENTE ])
    end

    it "não altera a conta que já existia" do
      cadastrar(nome: "Outra Pessoa")

      expect(Estudante.find_by(matricula: "250000001").nome).to eq("Aluno Existente")
    end

    it "reconhece a matrícula mesmo com espaços sobrando" do
      cadastro = cadastrar(matricula: " 250000001 ")

      expect(cadastro.erros).to eq([ CadastroEstudante::MSG_MATRICULA_EXISTENTE ])
    end
  end

  describe "combinação de problemas" do
    it "informa senhas diferentes e matrícula repetida juntas" do
      Estudante.create!(nome: "Aluno Existente", matricula: "250000001")

      cadastro = cadastrar(confirmacao_senha: "outra")

      expect(cadastro.erros).to contain_exactly(
        CadastroEstudante::MSG_SENHAS_DIFERENTES,
        CadastroEstudante::MSG_MATRICULA_EXISTENTE
      )
    end
  end

  describe "senha acima do limite do bcrypt" do
    it "recusa senha com mais de 72 bytes" do
      longa = "a" * 73
      cadastro = cadastrar(senha: longa, confirmacao_senha: longa)

      expect(cadastro.erros).to eq([ CadastroEstudante::MSG_SENHA_MUITO_LONGA ])
      expect(Estudante.count).to eq(0)
    end

    it "aceita senha com exatamente 72 bytes" do
      limite = "a" * 72

      expect(cadastrar(senha: limite, confirmacao_senha: limite)).to be_sucesso
    end
  end

  describe "corrida entre duas requisições com a mesma matrícula" do
    it "trata a violação do índice único como matrícula já cadastrada" do
      allow_any_instance_of(Estudante).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

      cadastro = cadastrar

      expect(cadastro).not_to be_sucesso
      expect(cadastro.erros).to eq([ CadastroEstudante::MSG_MATRICULA_EXISTENTE ])
      expect(cadastro.estudante).to be_nil
    end
  end
end