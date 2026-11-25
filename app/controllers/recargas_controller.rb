# frozen_string_literal: true

# Handles student recharge flows: PIX (QR code + confirmation) and credit card.
#
# All actions require an authenticated student (see +require_estudante!+).
class RecargasController < ApplicationController
  before_action :require_estudante!

  # Renders the form to choose a recharge method (PIX or credit card).
  #
  # @return [void]
  def new; end

  # Generates a PIX token and QR-code payload for the requested amount.
  #
  # Stores +pix_valor+ and +pix_token+ in the session so that
  # +confirmar_pix+ can validate the confirmation.
  #
  # @return [void]
  def create_pix
    @valor = valor_param
    @token = SecureRandom.hex(6)
    session[:pix_valor] = @valor
    session[:pix_token] = @token
    render :pix
  end

  # Confirms a PIX recharge using the token stored in session.
  #
  # On success, credits the student's balance and redirects with a notice.
  # On failure (invalid token or zero value), redirects with an alert.
  #
  # @return [void]
  def confirmar_pix
    valor = session.delete(:pix_valor)
    ok    = token_valido?(params[:token]) && valor.to_f.positive?

    if ok
      registrar_recarga(valor, "PIX")
      flash[:notice] = t(".success")
    else
      flash[:alert]  = t(".invalid")
    end
    redirect_to dashboard_path
  end

  # Processes a credit-card recharge with basic sanity checks.
  #
  # @return [void]
  def create_cartao
    valor  = valor_param
    numero = params[:numero].to_s.gsub(/\D/, "")
    cvv    = params[:cvv].to_s

    if cartao_valido?(numero, cvv, valor)
      registrar_recarga(valor, "Cartão de crédito")
      flash[:notice] = t(".success")
    else
      flash[:alert]  = t(".invalid")
    end
    redirect_to dashboard_path
  end

  private

  # @return [Float] the submitted value parsed from "1,50" or "1.50"
  def valor_param
    params[:valor].to_s.tr(",", ".").to_f
  end

  # @param token [String, nil]
  # @return [Boolean] true when the token matches the one stored in session
  def token_valido?(token)
    token.present? && token == session.delete(:pix_token)
  end

  # @return [Boolean] minimal validation for card number, CVV and value
  def cartao_valido?(numero, cvv, valor)
    numero.length >= 13 && cvv.length >= 3 && valor.positive?
  end

  # @param valor [Numeric]
  # @param forma [String]
  # @return [Recarga]
  def registrar_recarga(valor, forma)
    current_estudante.adicionar_recarga(
      Recarga.new(valor: valor, forma: forma, data: Date.today)
    )
  end
end
