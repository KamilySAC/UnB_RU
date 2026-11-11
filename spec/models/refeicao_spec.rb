require 'rails_helper'

RSpec.describe Refeicao, type: :model do
  subject(:refeicao) do
    described_class.new(restaurante: 'RU Central', valor: 8.5, data: Date.new(2026, 10, 10))
  end

  describe 'validações' do
    it { is_expected.to validate_numericality_of(:valor).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:restaurante) }
    it { is_expected.to validate_presence_of(:data) }

    it 'rejeita restaurante em branco' do
      refeicao.restaurante = '   '
      expect(refeicao).not_to be_valid
    end
  end

  describe 'associação' do
    it { is_expected.to belong_to(:estudante) }
  end

  describe 'nome da tabela (inflection portuguesa)' do
    it 'usa "refeicoes" como tabela' do
      expect(described_class.table_name).to eq('refeicoes')
    end
  end
end
