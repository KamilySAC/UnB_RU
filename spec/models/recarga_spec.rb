# spec/models/recarga_spec.rb
RSpec.describe Recarga, type: :model do
  it "happy path — valid attributes" do
    expect(build(:recarga)).to be_valid
  end

  it "sad path — zero value" do
    expect(build(:recarga, valor: 0)).not_to be_valid
  end

  it "sad path — unknown forma" do
    expect(build(:recarga, forma: "Boleto")).not_to be_valid
  end
end
