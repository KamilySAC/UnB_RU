require 'rails_helper'

RSpec.describe 'Extratos', type: :request do
  let!(:estudante) { Estudante.create!(email: 'aluno@teste.com', nome: 'Ana', saldo: 0) }
  let!(:outro)     { Estudante.create!(email: 'outro@teste.com', nome: 'Bia', saldo: 0) }

  before do
    estudante.adicionar_recarga(
      Recarga.new(valor: 50.0, forma: 'PIX', data: Date.new(2026, 10, 5))
    )
    estudante.refeicoes.create!(
      restaurante: 'RU Central', valor: 8.5, data: Date.new(2026, 10, 10)
    )
    outro.adicionar_recarga(
      Recarga.new(valor: 999.0, forma: 'PIX', data: Date.new(2026, 10, 5))
    )
    post login_path, params: { email: estudante.email }
  end

  describe 'GET /extrato/recargas' do
    it 'lista apenas as recargas do estudante logado' do
      get extrato_recargas_path
      expect(response.body).to include('R$ 50.00')
      expect(response.body).not_to include('R$ 999.00')
      expect(response.body).to include('Total recarregado')
    end

    it 'filtra por período' do
      get extrato_recargas_path, params: { inicio: '01/10/2026', fim: '31/10/2026' }
      expect(response.body).to include('R$ 50.00')
    end

    it 'período sem recargas mostra mensagem' do
      get extrato_recargas_path, params: { inicio: '01/01/2025', fim: '31/01/2025' }
      expect(response.body).to include('Nenhuma recarga encontrada no período')
    end
  end

  describe 'GET /extrato/refeicoes' do
    it 'lista as refeições do estudante logado' do
      get extrato_refeicoes_path
      expect(response.body).to include('RU Central')
      expect(response.body).to include('R$ 8.50')
      expect(response.body).to include('Total gasto')
    end

    it 'mostra mensagem quando não há refeições' do
      estudante.refeicoes.destroy_all
      get extrato_refeicoes_path
      expect(response.body).to include('Nenhuma refeição encontrada no período')
      expect(response.body).to include('Total gasto: R$ 0.00')
    end
  end

  describe 'GET /extrato/recargas/:id' do
    it 'mostra os detalhes de uma recarga' do
      recarga = estudante.recargas.first
      get detalhe_recarga_path(recarga)
      expect(response.body).to include('Detalhes da recarga')
      expect(response.body).to include('PIX')
      expect(response.body).to include('Aprovada')
    end
  end

  describe 'GET /meus_gastos' do
    it 'mostra as abas Recargas e Refeições' do
      get painel_path
      expect(response.body).to include('Recargas')
      expect(response.body).to include('Refeições')
      expect(response.body).to include('id="tabela_recargas"')
    end

    it 'aba Refeições mostra histórico' do
      get painel_path, params: { aba: 'refeicoes' }
      expect(response.body).to include('id="tabela_refeicoes"')
      expect(response.body).to include('RU Central')
    end
  end

  describe 'autenticação' do
    it 'exige login' do
      delete logout_path
      get extrato_recargas_path
      expect(response).to redirect_to(login_path)
    end
  end
end
