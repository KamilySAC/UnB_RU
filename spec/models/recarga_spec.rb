require "rails_helper"

RSpec.describe Recarga, type: :model do
  let(:estudante) do
    Estudante.create!(
      nome: "Arthur Santos",
      matricula: "242009990",
      grupo: "Grupo II",
      saldo: 10.00
    )
  end

  it "é válido com estudante, valor positivo e data" do
    recarga = estudante.recargas.build(valor: 20.00, forma: "PIX", data: Date.current)
    expect(recarga).to be_valid
  end

  it "é inválido sem data" do
    recarga = estudante.recargas.build(valor: 20.00, forma: "PIX", data: nil)
    expect(recarga).not_to be_valid
  end

  it "é inválido com valor zero ou negativo" do
    recarga_zero = estudante.recargas.build(valor: 0.00, data: Date.current)
    recarga_negativa = estudante.recargas.build(valor: -10.00, data: Date.current)

    expect(recarga_zero).not_to be_valid
    expect(recarga_negativa).not_to be_valid
  end
end

