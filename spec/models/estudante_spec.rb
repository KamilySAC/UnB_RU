# carrega config do rails e RSpec
require "rails_helper"

# Define a suite de testes da classe estudante. teste unitário de modelo (AcitveRecord)
RSpec.describe Estudante, tyoe: :model do
  # bloco 1: teste  das validações do model
  # describe agrupa um conjutno de testes relacionados a uma funcionalidade

  describe "validações do modelo" do
    # it define um cenário de teste individual
    it "é válido quando possui nome, matrícula, grupo e saldo válidos" do
      # cria um objeto em memória, não salva no banco
      estudante = Estudante.new(
        nome: "Arthur Santos",
        matricula: "242009990",
        grupo: "Grupo II",
        saldo: 10.00
      )

      # expect(...).to be_valid executa estudante.valid? e verifica se retorna true (passou na validação)
      expect(estudante.valid?).to be true
    end

    it "é inválido sem nome (validação presence:true)" do
      # cria com nome nulo para testar a obrigatoriedade
      estudante = Estudante.new(
        nome: nil,
        matricula: "123456",
        grupo: "Grupo II"
      )

      # expect(...).not_to be_valid: garante que o Rails rejeita o objeto
      expect(estudante).not_to be_valid

      # verifica se a mensagem de erro foi gerada especificamente para o atributo :nome
      expect(estudante.errors[:nome]).to be_present
    end

    it "nao permite matrículas duplicadas (validação uniqueness: true)" do
      # cria o primeiro estudante no banco de dados
      Estudante.create!(
        nome: "Aluno 1",
        matricula: "242009990",
        grupo: "Grupo II",
        saldo: 5.0
      )

      # tenta criar outro estudante com a mesma matrícula
      duplicado = Estudante.new(
        nome: "Aluno 2",
        matricula: "242009990",
        grupo: "Grupo II",
        saldo: 5.0
      )

      # o Rails deve impedir e adicionar erro no campo de matrícula
      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:matricula]).to be_present
    end

    it "não permite saldo negativo (validação numerically >= 0)" do
      # saldo negativo deve ser barrado pela validação
      estudante = Estudante.new(
        nome: "Arthur Santos",
        matricula: "242009990",
        grupo: "Grupo II",
        saldo: -10.00
      )

      expect(estudante).not_to be_valid
    end


    it "não permite grupo que não esteja na lista de grupos oficiais (validação inclusion)" do
      # grupo x não existe no array GRUPOS, logo deve ser inválido
      estudante = Estudante.new(
        nome: "Arthur Santos",
        matricula: "242009990",
        grupo: "Grupo X",
        saldo: 0.0
      )

      expect(estudante).not_to be_valid
    end
  end

  # Bloco 2: testes da função isento
  describe "#isento?" do
    it "retorna true para discentes do Grupo 1 (isenção integral)" do
      estudante = Estudante.new(grupo: "Grupo I")

      # testa se o retorno booleano é true.
      expect(estudante.isento?).to be true
    end


    it "retorna false para discentes pagantes (Grupo II, III e IV)" do
      # cria estudantes dos outros grupos para teste direto do retorno booleano 'false'
      expect(Estudante.new(grupo: "Grupo II").isento?).to be false

      expect(Estudante.new(grupo: "Grupo II").isento?).to be false

      expect(Estudante.new(grupo: "Grupo II").isento?).to be false
    end
  end


  # bloco da função tarifa_para(turno), verifica se o valor retornado é o esperado
  describe "#tarifa_para" do
    it "retorna R$ 0,00 em todos os discentes do grupo I" do
        estudante = Estudante.new(grupo: "Grupo I")

        # usa o 'to eq' para comparação de valor retornado e esperado
        expect(estudante.tarifa_para("Café da manhã")).to eq(0.00)

        expect(estudante.tarifa_para("Almoço")).to eq(0.00)

        expect(estudante.tarifa_para("Jantar")).to eq(0.00)
    end

    it "retorna tarifas corretas para o grupo II (Café: 2.00, Almoço: 4.50, Jantar: 4.50)" do
      estudante = Estudante.new(grupo: "Grupo II")

      expect(estudante.tarifa_para("Café da manhã")).to eq(2.00)

      expect(estudante.tarifa_para("Almoço")).to eq(4.50)

      expect(estudante.tarifa_para("Jantar")).to eq(4.50)
    end

    it "retorna tarifas corretas para o grupo III (Café: 7.05, Almoço: 15.20, Jantar: 15.20)" do
      estudante = Estudante.new(grupo: "Grupo III")

      expect(estudante.tarifa_para("Café da manhã")).to eq(7.05)

      expect(estudante.tarifa_para("Almoço")).to eq(15.20)

      expect(estudante.tarifa_para("Jantar")).to eq(15.20)
    end

    it "retorna tarifas corretas para o grupo IV (Café: 1.50, Almoço: 2.50, Jantar: 2.50)" do
      estudante = Estudante.new(grupo: "Grupo IV")

      expect(estudante.tarifa_para("Café da manhã")).to eq(1.50)

      expect(estudante.tarifa_para("Almoço")).to eq(2.50)

      expect(estudante.tarifa_para("Jantar")).to eq(2.50)
    end
  end
end
