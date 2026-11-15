
require "rails_helper"

RSpec.describe Recarga, type: :model do
  let(:estudante) do
    Estudante.create!(
      nome: "Ana",
      matricula: "242009990",
      grupo: "Grupo II",
      saldo: 10.00
    )
  end

  subject(:recarga) do
    described_class.new(
      estudante: estudante,
      valor: 50.0,
      forma: "PIX",
      data: Date.new(2026, 10, 5)
    )
  end

  describe "validações" do
    it { is_expected.to validate_numericality_of(:valor).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:data) }

    it "é válido com estudante, valor positivo e data" do
      expect(recarga).to be_valid
    end

    it "é inválido sem data" do
      recarga.data = nil

      expect(recarga).not_to be_valid
    end

    it "é inválido com valor zero ou negativo" do
      recarga.valor = 0.00
      expect(recarga).not_to be_valid

      recarga.valor = -10.00
      expect(recarga).not_to be_valid
    end

    it "aceita PIX e Cartão de crédito" do
      expect(recarga).to be_valid

      recarga.forma = "Cartão de crédito"
      expect(recarga).to be_valid
    end

    it "rejeita forma desconhecida" do
      recarga.forma = "Boleto"

      expect(recarga).not_to be_valid
      expect(recarga.errors[:forma]).to be_present
    end

    it "rejeita status desconhecido" do
      recarga.status = "Estranho"

      expect(recarga).not_to be_valid
    end

    it 'usa status "Aprovada" como padrão no banco' do
      estudante.recargas.create!(
        valor: 10,
        forma: "PIX",
        data: Date.today
      )

      expect(estudante.recargas.last.status).to eq("Aprovada")
    end
  end

  describe "associações" do
    it { is_expected.to belong_to(:estudante) }
  end
end
