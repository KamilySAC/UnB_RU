require "rails_helper"

RSpec.describe HistoricoGlobal do
  let!(:ru1) { Restaurante.create!(codigo: "RU-1", nome: "Restaurante 1", capacidade_por_hora: 100, total_pisos: 2) }
  let!(:ru2) { Restaurante.create!(codigo: "RU-2", nome: "Restaurante 2", capacidade_por_hora: 100, total_pisos: 2) }
  let!(:cat01) { ru1.catracas.create!(codigo: "CAT-01", nome: "Catraca 01", piso: 1, status: :online) }
  let!(:cat04) { ru1.catracas.create!(codigo: "CAT-04", nome: "Catraca 04", piso: 1, status: :online) }
  let!(:cat02) { ru2.catracas.create!(codigo: "CAT-02", nome: "Catraca 02", piso: 1, status: :online) }
  let!(:cat05) { ru2.catracas.create!(codigo: "CAT-05", nome: "Catraca 05", piso: 1, status: :online) }

  def criar_acesso(catraca, **atributos)
    catraca.acessos.create!({
                              matricula_discente: "MAT-TESTE",
                              turno: "Almoço",
                              modo_validacao: "Cartão",
                              tarifa: 2.50,
                              status_acesso: :liberado,
                              status_catraca: :online,
                              ocorrido_em: Time.current
                            }.merge(atributos))
  end

  before do
    criar_acesso(cat01, matricula_discente: "A1", tarifa: 2.50)
    criar_acesso(cat01, matricula_discente: "A2", tarifa: 4.50)
    criar_acesso(cat04, matricula_discente: "A3", tarifa: 2.00)
    criar_acesso(cat02, matricula_discente: "A4", tarifa: 3.00)
    criar_acesso(cat02, matricula_discente: "A5", tarifa: 0, status_acesso: :bloqueado, motivo_negativa: "Saldo Insuficiente")
    criar_acesso(cat02, matricula_discente: "A6", tarifa: 0, status_acesso: :bloqueado, motivo_negativa: "Janela Expirada")
  end

  describe "sem filtros" do
    subject(:historico) { described_class.new }

    it "lista os acessos de todas as catracas, do mais recente para o mais antigo" do
      expect(historico.acessos.map(&:matricula_discente)).to match_array(%w[A1 A2 A3 A4 A5 A6])
    end

    it "soma o total de acessos (inclui bloqueados) e a arrecadação só dos liberados" do
      expect(historico.total_acessos).to eq(6)
      expect(historico.arrecadacao_bruta).to eq(BigDecimal("12.00"))
    end

    it "informa quando não há acessos" do
      Acesso.delete_all

      expect(historico.sem_acessos?).to be(true)
      expect(historico.arrecadacao_bruta).to eq(0)
    end
  end

  describe "filtros" do
    it "filtra por restaurante" do
      historico = described_class.new(restaurante: ru1)

      expect(historico.acessos.map(&:matricula_discente)).to match_array(%w[A1 A2 A3])
    end

    it "filtra por catraca do restaurante" do
      historico = described_class.new(restaurante: ru1, catraca: cat04)

      expect(historico.acessos.map(&:matricula_discente)).to eq(%w[A3])
    end

    it "ignora a catraca que não pertence ao restaurante selecionado" do
      historico = described_class.new(restaurante: ru2, catraca: cat04)

      expect(historico.catraca).to be_nil
      expect(historico.acessos.map(&:matricula_discente)).to match_array(%w[A4 A5 A6])
    end

    it "só oferece as catracas do restaurante selecionado" do
      expect(described_class.new(restaurante: ru2).catracas_disponiveis).to contain_exactly(cat02, cat05)
      expect(described_class.new.catracas_disponiveis).to contain_exactly(cat01, cat02, cat04, cat05)
    end

    it "não tem acessos para a catraca sem registros" do
      historico = described_class.new(catraca: cat05)

      expect(historico.sem_acessos?).to be(true)
    end

    it "ignora agrupamento desconhecido" do
      expect(described_class.new(agrupar: "turno").agrupar).to be_nil
      expect(described_class.new(agrupar: "catraca").agrupar).to eq("catraca")
    end
  end

  describe "#linhas_por_restaurante" do
    subject(:linhas) { described_class.new(agrupar: "restaurante").linhas_por_restaurante }

    it "traz uma linha por restaurante com acessos, pontualidade e arrecadação" do
      expect(linhas.map(&:nome)).to eq([ "Restaurante 1", "Restaurante 2" ])

      r1, r2 = linhas
      expect([ r1.acessos, r1.arrecadacao, r1.pontualidade ]).to eq([ 3, BigDecimal("9.00"), 100.0 ])
      # 3 acessos, 1 deles bloqueado por janela expirada
      expect([ r2.acessos, r2.arrecadacao, r2.pontualidade ]).to eq([ 3, BigDecimal("3.00"), 66.7 ])
    end

    it "fecha com o total consolidado igual à soma das linhas" do
      total = described_class.new.totais

      expect(total.acessos).to eq(linhas.sum(&:acessos))
      expect(total.arrecadacao).to eq(linhas.sum(&:arrecadacao))
    end

    it "mostra restaurante sem acessos com zeros e sem pontualidade" do
      ru3 = Restaurante.create!(codigo: "RU-3", nome: "Restaurante 3", capacidade_por_hora: 10, total_pisos: 1)

      linha = described_class.new.linhas_por_restaurante.find { |l| l.nome == ru3.nome }

      expect([ linha.acessos, linha.arrecadacao, linha.pontualidade ]).to eq([ 0, 0, nil ])
    end

    it "considera a janela expirada sem diferenciar maiúsculas" do
      criar_acesso(cat01, status_acesso: :bloqueado, motivo_negativa: "janela expirada", tarifa: 0)

      r1 = described_class.new.linhas_por_restaurante.first

      expect(r1.pontualidade).to eq(75.0)
    end
  end

  describe "#linhas_por_catraca" do
    it "traz uma linha por catraca com passagens e total debitado" do
      linhas = described_class.new(agrupar: "catraca").linhas_por_catraca.index_by(&:nome)

      expect(linhas.size).to eq(4)
      expect(linhas["Restaurante 1 - Catraca 01"]).to have_attributes(passagens: 2, arrecadacao: BigDecimal("7.00"))
      # bloqueados não contam como passagem nem como valor debitado
      expect(linhas["Restaurante 2 - Catraca 02"]).to have_attributes(passagens: 1, arrecadacao: BigDecimal("3.00"))
      expect(linhas["Restaurante 2 - Catraca 05"]).to have_attributes(passagens: 0, arrecadacao: 0)
    end

    it "respeita o filtro de restaurante" do
      linhas = described_class.new(restaurante: ru1, agrupar: "catraca").linhas_por_catraca

      expect(linhas.map(&:nome)).to eq([ "Restaurante 1 - Catraca 01", "Restaurante 1 - Catraca 04" ])
    end
  end
end