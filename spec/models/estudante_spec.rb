# spec/models/estudante_spec.rb
RSpec.describe Estudante, type: :model do
  describe "#adicionar_recarga" do
    let(:estudante) { create(:estudante, saldo: 5.0) }

    it "happy path — increases saldo" do
      estudante.adicionar_recarga(build(:recarga, valor: 10.0, estudante: nil))
      expect(estudante.reload.saldo).to eq(15.0)
    end

    it "sad path — invalid recarga raises" do
      expect {
        estudante.adicionar_recarga(build(:recarga, valor: -1))
      }.to raise_error(ActiveRecord::RecordInvalid)
      expect(estudante.reload.saldo).to eq(5.0)
    end
  end
end
