require "rails_helper"

RSpec.describe "Historicos", type: :request do
  let!(:estudante) do
    Estudante.create!(
      nome: "Arthur Santos",
      matricula: "242009990",
      grupo: "Grupo II",
      saldo: 30.00
    )
  end

  describe "GET /historico/exportar_pdf" do
    context "quando o estudante possui movimentações no mês atual" do
      before do
        estudante.recargas.create!(
          valor: 50.00,
          forma: "PIX",
          status: "Aprovada",
          data: Date.current
        )
      end

      it "retorna status 200 com o arquivo PDF para download" do
        get exportar_historico_pdf_path

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include('attachment; filename="historico_estudante.pdf"')
        expect(response.body.start_with?("%PDF")).to be true
      end
    end

    context "quando o estudante não possui movimentações no mês atual" do
      before do
        estudante.recargas.destroy_all
        estudante.refeicoes.destroy_all
      end

      it "retorna status 422 informando a ausência de movimentações" do
        get exportar_historico_pdf_path

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Não há movimentações registradas no mês atual")
      end
    end
  end
end
