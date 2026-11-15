
require "rails_helper"

RSpec.describe Refeicao, type: :model do
  let(:estudante) do
    Estudante.create!(
      nome: "Ana",
      matricula: "242009990",
      grupo: "Grupo II",
      saldo: 10.00
    )
  end

  subject(:refeicao) do
    estudante.refeicoes.build(
      restaurante: "RU Central",
      valor: 8.50,
      data: Date.new(2026, 10, 10)
    )
  end

  describe "validações" do
    it { is_expected.to validate_numericality_of(:valor).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:restaurante) }
    it { is_expected.to validate_presence_of(:data) }

    it "é válida com estudante, restaurante, valor positivo e data" do
      expect(refeicao).to be_valid
    end

    it "é inválida sem restaurante" do
      refeicao.restaurante = nil

      expect(refeicao).not_to be_valid
    end

    it "rejeita restaurante em branco" do
      refeicao.restaurante = "   "

      expect(refeicao).not_to be_valid
    end

    it "é inválida sem data" do
      refeicao.data = nil

      expect(refeicao).not_to be_valid
    end

    it "é inválida com valor zero ou negativo" do
      refeicao.valor = 0.00
      expect(refeicao).not_to be_valid

      refeicao.valor = -4.50
      expect(refeicao).not_to be_valid
    end
  end

  describe "associações" do
    it { is_expected.to belong_to(:estudante) }
  end

  describe "nome da tabela (inflection portuguesa)" do
    it 'usa "refeicoes" como tabela' do
      expect(described_class.table_name).to eq("refeicoes")
    end
  end
end
