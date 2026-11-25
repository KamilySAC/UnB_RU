# frozen_string_literal: true

# Exports the student's current-month history as a downloadable PDF.
class HistoricosController < ApplicationController
  allow_browser versions: :all if respond_to?(:allow_browser)

  # GET /historico/exportar_pdf
  #
  # Streams a PDF when the student has movements in the current month;
  # otherwise responds with 422 and a message.
  #
  # @return [void]
  def exportar_pdf
    estudante = current_estudante
    return redirect_to(root_path, alert: t(".not_authenticated")) unless estudante

    gerador = GeradorHistoricoPdf.new(estudante)
    return render_no_movements unless gerador.possui_movimentacoes?

    send_data gerador.gerar,
              filename: GeradorHistoricoPdf::NOME_ARQUIVO,
              type: "application/pdf",
              disposition: "attachment"
  end

  private

  # @return [void]
  def render_no_movements
    msg = t(".no_movements")
    flash[:alert] = msg
    render plain: msg, status: :unprocessable_entity
  end

  # @return [Estudante, nil]
  def current_estudante
    @current_estudante ||= Estudante.find_by(id: session[:estudante_id])
  end
end
