# spec/controllers/historicos_controller_spec.rb
require "rails_helper"

RSpec.describe HistoricosController, type: :controller do
  let(:estudante) { create(:estudante) }

  before { session[:estudante_id] = estudante.id }

  describe "GET #exportar_pdf" do
    context "happy path — has movements" do
      before do
        allow_any_instance_of(GeradorHistoricoPdf)
          .to receive(:possui_movimentacoes?).and_return(true)
        allow_any_instance_of(GeradorHistoricoPdf)
          .to receive(:gerar).and_return("%PDF-1.4 fake")
      end

      it "sends the PDF as attachment" do
        get :exportar_pdf
        expect(response).to have_http_status(:success)
        expect(response.headers["Content-Type"]).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("attachment")
      end
    end

    context "sad path — no movements" do
      before do
        allow_any_instance_of(GeradorHistoricoPdf)
          .to receive(:possui_movimentacoes?).and_return(false)
      end

      it "returns 422 with a message" do
        get :exportar_pdf
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/não há movimentações/i)
      end
    end

    context "sad path — not authenticated" do
      before { session.delete(:estudante_id) }

      it "redirects to root" do
        get :exportar_pdf
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
