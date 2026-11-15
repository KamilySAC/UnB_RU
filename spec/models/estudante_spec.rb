
require "rails_helper"

RSpec.describe Estudante, type: :model do
  subject(:estudante) do
    described_class.new(
      nome: "Ana",
      matricula: "242009990",
      grupo: "Grupo II",
      saldo: 0.0
    )
  end

  describe "validações" do
    it { is_expected.to validate_presence_of(:nome) }
    it { is_expected.to validate_presence_of(:matricula) }
    it { is_expected.to validate_uniqueness_of(:matricula).ignoring_case_sensitivity }
    it { is_expected.to validate_inclusion_of(:grupo).in_array(Estudante::GRUPOS) }
        it { is_expected.to validate_numericality_of(:saldo).is_greater_than_or_equal_to(0.0) }

    it "é válido quando possui nome, matrícula, grupo e saldo válidos" do
      expect(estudante).to be_valid
    end

    it "é inválido sem nome" do
      estudante.nome = nil

      expect(estudante).not_to be_valid
      expect(estudante.errors[:nome]).to be_present
    end

    it "não permite matrículas duplicadas" do
      Estudante.create!(
        nome: "Aluno 1",
        matricula: "242009991",
        grupo: "Grupo II",
        saldo: 5.0
      )

      duplicado = Estudante.new(
        nome: "Aluno 2",
        matricula: "242009991",
        grupo: "Grupo II",
        saldo: 5.0
      )

      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:matricula]).to be_present
    end

    it "não permite saldo negativo" do
      estudante.saldo = -10.00

      expect(estudante).not_to be_valid
    end

    it "não permite grupo fora da lista oficial" do
      estudante.grupo = "Grupo X"

      expect(estudante).not_to be_valid
    end
  end

  describe "associações" do
    it { is_expected.to have_many(:recargas).dependent(:destroy) }
    it { is_expected.to have_many(:refeicoes).class_name("Refeicao").dependent(:destroy) }
    it { is_expected.to have_many(:acessos_catraca).class_name("AcessoCatraca").dependent(:destroy) }
  end

  describe "#adicionar_recarga" do
    let(:recarga) do
      Recarga.new(
        valor: 50.0,
        forma: "PIX",
        data: Date.new(2026, 10, 5)
      )
    end

    it "incrementa o saldo" do
      estudante.save!

      expect {
        estudante.adicionar_recarga(recarga)
      }.to change { estudante.reload.saldo }.from(0.0).to(50.0)
    end

    it "persiste a recarga associada" do
      estudante.save!
      estudante.adicionar_recarga(recarga)

      expect(estudante.recargas.reload.count).to eq(1)
    end

    it "acumula múltiplas recargas" do
      estudante.save!
      estudante.adicionar_recarga(recarga)

      estudante.adicionar_recarga(
        Recarga.new(
          valor: 30.0,
          forma: "Cartão de crédito",
          data: Date.new(2026, 10, 6)
        )
      )

      expect(estudante.reload.saldo).to eq(80.0)
    end

    it "é transacional: se a recarga falhar, o saldo não muda" do
      estudante.save!
      invalida = Recarga.new(
        valor: -10,
        forma: "PIX",
        data: Date.new(2026, 10, 5)
      )

      expect {
        estudante.adicionar_recarga(invalida) rescue nil
      }.not_to change { estudante.reload.saldo }
    end
  end

  describe "#isento?" do
    it "retorna true para discentes do Grupo I" do
      expect(Estudante.new(grupo: "Grupo I").isento?).to be true
    end

    it "retorna false para discentes dos grupos pagantes" do
      %w[II III IV].each do |grupo|
        expect(Estudante.new(grupo: "Grupo #{grupo}").isento?).to be false
      end
    end
  end

  describe "#tarifa_para" do
    it "retorna R$ 0,00 para o Grupo I em todos os turnos" do
      estudante = Estudante.new(grupo: "Grupo I")

      expect(estudante.tarifa_para("Café da manhã")).to eq(0.00)
      expect(estudante.tarifa_para("Almoço")).to eq(0.00)
      expect(estudante.tarifa_para("Jantar")).to eq(0.00)
    end

    it "retorna as tarifas corretas para o Grupo II" do
      estudante = Estudante.new(grupo: "Grupo II")

      expect(estudante.tarifa_para("Café da manhã")).to eq(2.00)
      expect(estudante.tarifa_para("Almoço")).to eq(4.50)
      expect(estudante.tarifa_para("Jantar")).to eq(4.50)
    end

    it "retorna as tarifas corretas para o Grupo III" do
      estudante = Estudante.new(grupo: "Grupo III")

      expect(estudante.tarifa_para("Café da manhã")).to eq(7.05)
      expect(estudante.tarifa_para("Almoço")).to eq(15.20)
      expect(estudante.tarifa_para("Jantar")).to eq(15.20)
    end

    it "retorna as tarifas corretas para o Grupo IV" do
      estudante = Estudante.new(grupo: "Grupo IV")

      expect(estudante.tarifa_para("Café da manhã")).to eq(1.50)
      expect(estudante.tarifa_para("Almoço")).to eq(2.50)
      expect(estudante.tarifa_para("Jantar")).to eq(2.50)
    end
  end
end
