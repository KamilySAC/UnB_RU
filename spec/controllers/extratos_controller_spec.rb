# spec/controllers/extratos_controller_spec.rb
require "rails_helper"

RSpec.describe ExtratosController, type: :controller do
  let(:estudante) { create(:estudante) }

  before do
    session[:estudante_id] = estudante.id
  end

  describe "GET #recargas" do
    context "happy path — com filtro de data" do
      before do
        create(:recarga, estudante: estudante, data: Date.new(2025, 1, 10), valor: 20.0)
        create(:recarga, estudante: estudante, data: Date.new(2025, 2, 10), valor: 30.0)
      end

      it "filtra pelo período e calcula o total" do
        get :recargas, params: { inicio: "01/01/2025", fim: "31/01/2025" }
        expect(assigns(:recargas).size).to eq(1)
        expect(assigns(:total)).to eq(20.0)
      end
    end

    context "sad path — data inválida" do
      before do
        create(:recarga, estudante: estudante, valor: 10.0)
      end

      it "ignora a data inválida e retorna todas as recargas" do
        get :recargas, params: { inicio: "data-invalida" }
        expect(assigns(:recargas).size).to eq(1)
      end
    end
  end

  describe "GET #refeicoes" do
    context "happy path — com filtro de data" do
      before do
        create(:refeicao, estudante: estudante, data: Date.new(2025, 1, 10), valor: 5.0)
        create(:refeicao, estudante: estudante, data: Date.new(2025, 2, 10), valor: 7.0)
      end

      it "filtra pelo período e calcula o total" do
        get :refeicoes, params: { inicio: "01/01/2025", fim: "31/01/2025" }
        expect(assigns(:refeicoes).size).to eq(1)
        expect(assigns(:total)).to eq(5.0)
      end
    end
  end

  describe "GET #detalhe_recarga" do
    let!(:recarga) { create(:recarga, estudante: estudante) }

    it "happy path — encontra a recarga" do
      get :detalhe_recarga, params: { id: recarga.id }
      expect(response).to have_http_status(:success)
    end

    it "sad path — recarga de outro estudante" do
      outra_recarga = create(:recarga) # pertence a outro estudante
      expect {
        get :detalhe_recarga, params: { id: outra_recarga.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
