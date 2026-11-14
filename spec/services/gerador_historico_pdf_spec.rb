# carrega config do rails e rspec
require "rails_helper"

RSpec.describe GeradorHistoricoPdf, type: :service do
  # cria um estudante base para testes
  let(:estudante) do
    Estudante.create!(
      nome: "Arthur Santos",
      matricula: "242009990",
      grupo: "Grupo II",
      saldo: 15.50
    )
  end

  # fixa uma data para os testes
  let(:data_teste) {
    Date.new(2026, 11, 10)
  }


  # bloco 1 - cenário com movimentações no mês atual - cenário feliz
  describe "#gerar com movimentações no mês atual" do
    before do
      # cria dados de recarga para teste

      # recargas de novembro de 2026
      estudante.recargas.create!(valor: 30.00, forma: "PIX", data: Date.new(2026, 11, 2))
      estudante.recargas.create!(valor: 20.00, forma: "PIX", data: Date.new(2026, 11, 5))

      # refeições consumidas no mês de novembro
      estudante.refeicoes.create!(valor: 4.50, data: Date.new(2026, 11, 3), restaurante: "RU Darcy")
      estudante.refeicoes.create!(valor: 4.50, data: Date.new(2026, 11, 4), restaurante: "RU Darcy")
    end

    it "reconhece que há movimentações no mês vigente" do
      gerador = GeradorHistoricoPdf.new(estudante, data_referencia: data_teste)

      # teste booleano que deve retornar true
      expect(gerador.possui_movimentacoes?).to be true
    end


    it "calcula corretamente os totais de recarga e consumos do mês" do
      gerador = GeradorHistoricoPdf.new(estudante, data_referencia: data_teste)

      # soma das recargas: 30 + 20 = 50.00
      expect(gerador.total_recarregado).to eq(50.00)

      # soma das refeições: 4.50 + 4.50 = 9.00
      expect(gerador.total_consumido).to eq(9.00)
    end

    it "gera um arquivo PDF binário válido iniciado com o cabeçalho %PDF" do
      gerador = GeradorHistoricoPdf.new(estudante, data_referencia: data_teste)
      pdf = gerador.gerar

      expect(pdf).not_to be_nil
      expect(pdf.bytesize).to be > 1000
      expect(pdf).to start_with("%PDF")
    end
  end


  # bloco 2: regra de isolamento de meses anteriores
  describe "isolamento de meses anteriores" do
    before do
      # movimentações do mês passado - outubro
      estudante.recargas.create!(valor: 100.00, data: Date.new(2026, 10, 15))
      estudante.refeicoes.create!(valor: 40.00, data: Date.new(2026, 10, 20), restaurante: "RU Darcy")

      # movimentações do mês de teste - novembro
      estudante.recargas.create!(valor: 25.00, data: Date.new(2026, 11, 5))
      estudante.refeicoes.create!(valor: 4.50, data: Date.new(2026, 11, 10), restaurante: "RU Darcy")
    end

    it "ignora totalmente as movimentações de meses anteriores nos totais" do
      gerador = GeradorHistoricoPdf.new(estudante, data_referencia: data_teste)

      # conta apenas o valor de novembro - atual, e ignora de outubro.
      expect(gerador.total_recarregado).to eq(25.00)
      expect(gerador.total_consumido).to eq(4.50)
    end
  end

  # bloco 3: cenário sem movimentações no mês atual
  describe "#gerar sem movimentações no mês atual" do
    it "retorna nil e indica que não há movimentações" do
      gerador = GeradorHistoricoPdf.new(estudante, data_referencia: data_teste)

      expect(gerador.possui_movimentacoes?).to be false
      expect(gerador.gerar).to be_nil
    end
  end
end
