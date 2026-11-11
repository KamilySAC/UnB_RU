require "rails_helper"

RSpec.describe Refeicao, type: :model do
  let(:estudante) do
    Estudante.create!(
      nome: "Arthur Santos",
      matricula: "242009990",
      grupo: "Grupo II",
      saldo: 10.00
    )
  end

  it "é válido com estudante, restaurante, valor positivo e data" do
    refeicao = estudante.refeicoes.build(
      restaurante: "RU Darcy Ribeiro",
      valor: 4.50,
      data: Date.current
    )
    expect(refeicao).to be_valid
  end

  it "é inválido sem restaurante" do
    refeicao = estudante.refeicoes.build(restaurante: nil, valor: 4.50, data: Date.current)
    expect(refeicao).not_to be_valid
  end

  it "é inválido sem data" do
    refeicao = estudante.refeicoes.build(restaurante: "RU Darcy Ribeiro", valor: 4.50, data: nil)
    expect(refeicao).not_to be_valid
  end

  it "é inválido com valor zero ou negativo" do
    refeicao_zero = estudante.refeicoes.build(restaurante: "RU", valor: 0.00, data: Date.current)
    refeicao_negativa = estudante.refeicoes.build(restaurante: "RU", valor: -4.50, data: Date.current)

    expect(refeicao_zero).not_to be_valid
    expect(refeicao_negativa).not_to be_valid
  end
end

