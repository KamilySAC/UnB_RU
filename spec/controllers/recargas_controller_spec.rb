# spec/controllers/recargas_controller_spec.rb
require "rails_helper"

RSpec.describe RecargasController, type: :controller do
  let(:estudante) { create(:estudante, saldo: 0) }

  before do
    session[:estudante_id] = estudante.id
  end

  describe "POST #create_pix" do
    it "armazena valor e token na sessão" do
      post :create_pix, params: { valor: "10,50" }
      expect(session[:pix_valor]).to eq(10.5)
      expect(session[:pix_token]).to be_present
    end
  end

  describe "POST #confirmar_pix" do
    context "happy path — token válido" do
      before do
        session[:pix_valor] = 10.0
        session[:pix_token] = "abc123"
      end

      it "cria a recarga e atualiza o saldo" do
        post :confirmar_pix, params: { token: "abc123" }
        expect(estudante.reload.saldo).to eq(10.0)
        expect(flash[:notice]).to be_present
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "sad path — token inválido" do
      before do
        session[:pix_valor] = 10.0
        session[:pix_token] = "abc123"
      end

      it "não credita o saldo" do
        post :confirmar_pix, params: { token: "errado" }
        expect(estudante.reload.saldo).to eq(0.0)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST #create_cartao" do
    it "happy path — cartão válido" do
      post :create_cartao, params: {
        valor: "15", numero: "4111111111111111", cvv: "123"
      }
      expect(estudante.reload.saldo).to eq(15.0)
      expect(flash[:notice]).to be_present
    end

    it "sad path — cartão inválido" do
      post :create_cartao, params: {
        valor: "15", numero: "123", cvv: "1"
      }
      expect(estudante.reload.saldo).to eq(0.0)
      expect(flash[:alert]).to eq("Dados do cartão inválidos")
    end
  end
end
