require "rails_helper"

RSpec.describe Funcionario, type: :model do
  def funcionario(attrs = {})
    Funcionario.new({
      nome: "Fulano D.", matricula_siape: "2948102", usuario: "fulano.fiscal",
      password: "Senha@123", papel: "fiscal"
    }.merge(attrs))
  end

  describe "validações" do
    it "é válido com todos os dados" do
      expect(funcionario).to be_valid
    end

    it "exige nome, matrícula e senha" do
      expect(funcionario(nome: "")).not_to be_valid
      expect(funcionario(matricula_siape: "")).not_to be_valid
      expect(funcionario(password: nil)).not_to be_valid
    end

    it "exige matrícula SIAPE com 7 dígitos" do
      expect(funcionario(matricula_siape: "12345")).not_to be_valid
      expect(funcionario(matricula_siape: "abcdefg")).not_to be_valid
    end

    it "não permite a mesma matrícula nem o mesmo usuário duas vezes" do
      funcionario.save!

      expect(funcionario(usuario: "outro.usuario")).not_to be_valid
      expect(funcionario(matricula_siape: "7654321", usuario: "FULANO.FISCAL")).not_to be_valid
    end

    it "permite vários funcionários sem usuário" do
      funcionario(usuario: nil).save!

      expect(funcionario(matricula_siape: "7654321", usuario: "")).to be_valid
    end

    it "não aceita usuário só com números" do
      expect(funcionario(usuario: "1234567")).not_to be_valid
    end

    it "exige senha com pelo menos 8 caracteres" do
      expect(funcionario(password: "Ab@1")).not_to be_valid
    end

    it "aceita apenas os papéis fiscal e administrador" do
      expect(funcionario(papel: "administrador")).to be_valid
      expect(funcionario(papel: "chefe")).not_to be_valid
    end

    it "guarda a senha como hash" do
      salvo = funcionario.tap(&:save!)

      expect(salvo.password_digest).not_to include("Senha@123")
    end
  end

  describe ".autenticar" do
    let!(:salvo) { funcionario.tap(&:save!) }

    it "autentica por matrícula SIAPE ou por usuário" do
      expect(Funcionario.autenticar("2948102", "Senha@123")).to eq(salvo)
      expect(Funcionario.autenticar("  Fulano.Fiscal ", "Senha@123")).to eq(salvo)
    end

    it "retorna nil com senha incorreta ou identificador não cadastrado" do
      expect(Funcionario.autenticar("2948102", "SenhaErrada")).to be_nil
      expect(Funcionario.autenticar("0000000", "Senha@123")).to be_nil
    end
  end
end