# spec/controllers/recargas_controller_spec.rb
require "rails_helper"

RSpec.describe RecargasController, type: :controller do
  let(:estudante) { create(:estudante, saldo: 0) }
  before { session[:estudante_id] = estudante.id }

  describe "POST #create_pix" do
    it "stores valor and token in session" do
      post :create_pix, params: { valor: "10,50" }
      expect(session[:pix_valor]).to eq(10.5)
      expect(session[:pix_token]).to be_present
    end
  end

  describe "POST #confirmar_pix" do
    context "happy path — valid token" do
      before do
        session[:pix_valor] = 10.0
        session[:pix_token] = "abc123"
      end

      it "creates a recarga and updates saldo" do
        post :confirmar_pix, params: { token: "abc123" }
        expect(estudante.reload.saldo).to eq(10.0)
        expect(flash[:notice]).to be_present
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "sad path — invalid token" do
      before do
        session[:pix_valor] = 10.0
        session[:pix_token] = "abc123"
      end

      it "does not credit the saldo" do
        post :confirmar_pix, params: { token: "wrong" }
        expect(estudante.reload.saldo).to eq(0.0)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST #create_cartao" do
    it "happy path — credits saldo" do
      post :create_cartao, params: {
        valor: "15", numero: "4111111111111111", cvv: "123"
      }
      expect(estudante.reload.saldo).to eq(15.0)
    end

    it "sad path — invalid card" do
      post :create_cartao, params: {
        valor: "15", numero: "123", cvv: "1"
      }
      expect(estudante.reload.saldo).to eq(0.0)
      expect(flash[:alert]).to eq("Dados do cartão inválidos")
    end
  end
end
