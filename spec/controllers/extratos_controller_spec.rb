# spec/controllers/extratos_controller_spec.rb
require "rails_helper"

RSpec.describe ExtratosController, type: :controller do
  let(:estudante) { create(:estudante) }
  before { session[:estudante_id] = estudante.id }

  describe "GET #recargas" do
    context "happy path — with a date filter" do
      before do
        create(:recarga, estudante: estudante, data: Date.new(2025, 1, 10), valor: 20.0)
        create(:recarga, estudante: estudante, data: Date.new(2025, 2, 10), valor: 30.0)
      end

      it "filters and sums correctly" do
        get :recargas, params: { inicio: "01/01/2025", fim: "31/01/2025" }
        expect(assigns(:recargas).size).to eq(1)
        expect(assigns(:total)).to eq(20.0)
      end
    end

    context "sad path — invalid date" do
      before { create(:recarga, estudante: estudante, valor: 10.0) }

      it "ignores invalid input and returns all" do
        get :recargas, params: { inicio: "not-a-date" }
        expect(assigns(:recargas).size).to eq(1)
      end
    end
  end

  describe "GET #detalhe_recarga" do
    let!(:recarga) { create(:recarga, estudante: estudante) }

    it "happy path — found" do
      get :detalhe_recarga, params: { id: recarga.id }
      expect(response).to have_http_status(:success)
    end

    it "sad path — not owned by student" do
      other = create(:recarga)
      expect {
        get :detalhe_recarga, params: { id: other.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
