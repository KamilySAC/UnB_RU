require 'rails_helper'

RSpec.describe Estudante, type: :model do
  subject(:estudante) { described_class.new(email: 'ana@teste.com', nome: 'Ana') }

  describe 'validações' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:nome) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_numericality_of(:saldo).is_greater_than_or_equal_to(0) }
  end

  describe 'associações' do
    it { is_expected.to have_many(:recargas).dependent(:destroy) }
    it { is_expected.to have_many(:refeicoes).class_name('Refeicao').dependent(:destroy) }
  end

  describe '#adicionar_recarga' do
    let(:recarga) { Recarga.new(valor: 50.0, forma: 'PIX', data: Date.new(2026, 10, 5)) }

    it 'incrementa o saldo' do
      expect { estudante.adicionar_recarga(recarga) }.to change { estudante.saldo }.from(0.0).to(50.0)
    end

    it 'persiste a recarga associada' do
      estudante.save!
      estudante.adicionar_recarga(recarga)
      expect(estudante.recargas.reload.count).to eq(1)
    end

    it 'acumula múltiplas recargas' do
      estudante.save!
      estudante.adicionar_recarga(recarga)
      estudante.adicionar_recarga(
        Recarga.new(valor: 30.0, forma: 'Cartão de crédito', data: Date.new(2026, 10, 6))
      )
      expect(estudante.saldo).to eq(80.0)
    end

    it 'é transacional: se falhar a recarga, saldo não muda' do
      estudante.save!
      invalida = Recarga.new(valor: -10, forma: 'PIX', data: Date.new(2026, 10, 5))
      expect {
        estudante.adicionar_recarga(invalida) rescue nil
      }.not_to change { estudante.saldo }
    end
  end
end
