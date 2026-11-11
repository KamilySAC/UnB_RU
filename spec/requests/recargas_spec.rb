require 'rails_helper'

RSpec.describe 'Recargas', type: :request do
  let!(:estudante) { Estudante.create!(email: 'aluno@teste.com', nome: 'Ana', saldo: 0) }

  def login
    post login_path, params: { email: estudante.email }
  end

  describe 'POST /recarga/pix + confirmar' do
    it 'incrementa o saldo e exibe mensagem de sucesso' do
      login
      post recarga_pix_path, params: { valor: '50,00' }
      token = response.body[/QR-Code-(\w+)-/, 1]
      post recarga_pix_confirmar_path, params: { token: token }

      expect(response).to redirect_to(dashboard_path)
      follow_redirect!
      expect(response.body).to include('Recarga realizada com sucesso')
      expect(response.body).to include('Saldo: R$ 50.00')
      expect(estudante.reload.saldo).to eq(50.0)
    end

    it 'não incrementa saldo quando o token é inválido' do
      login
      post recarga_pix_confirmar_path, params: { token: 'invalido' }
      expect(estudante.reload.saldo).to eq(0.0)
    end
  end

  describe 'POST /recarga/cartao' do
    it 'aceita cartão válido e incrementa saldo' do
      login
      post recarga_cartao_path, params: {
        valor: '100,00', numero: '4111111111111111', cvv: '123'
      }
      expect(response.body).to include('Recarga realizada com sucesso') if response.body.present?
      expect(estudante.reload.saldo).to eq(100.0)
    end

    it 'rejeita cartão inválido e mantém saldo' do
      login
      post recarga_cartao_path, params: {
        valor: '100,00', numero: '12', cvv: '1'
      }
      follow_redirect!
      expect(response.body).to include('Dados do cartão inválidos')
      expect(estudante.reload.saldo).to eq(0.0)
    end
  end

  describe 'autenticação' do
    it 'exige login para acessar /recarga' do
      get recarga_path
      expect(response).to redirect_to(login_path)
    end
  end
end
