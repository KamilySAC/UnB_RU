class RecargasController < ApplicationController
  before_action :require_estudante!

  def new; end

  def create_pix
    @valor = params[:valor].to_s.tr(',', '.').to_f
    @token = SecureRandom.hex(6)
    session[:pix_valor] = @valor
    session[:pix_token] = @token
    render :pix
  end

  def confirmar_pix
    valor = session.delete(:pix_valor)
    token_valido = params[:token].present? && params[:token] == session.delete(:pix_token)
    if token_valido && valor.to_f.positive?
      current_estudante.adicionar_recarga(
        Recarga.new(valor: valor, forma: 'PIX', data: Date.today)
      )
      flash[:notice] = 'Recarga realizada com sucesso'
    else
      flash[:alert] = 'Pagamento não identificado'
    end
    redirect_to dashboard_path
  end

  def create_cartao
    valor  = params[:valor].to_s.tr(',', '.').to_f
    numero = params[:numero].to_s.gsub(/\D/, '')
    cvv    = params[:cvv].to_s

    if numero.length >= 13 && cvv.length >= 3 && valor.positive?
      current_estudante.adicionar_recarga(
        Recarga.new(valor: valor, forma: 'Cartão de crédito', data: Date.today)
      )
      flash[:notice] = 'Recarga realizada com sucesso'
    else
      flash[:alert] = 'Dados do cartão inválidos'
    end
    redirect_to dashboard_path
  end
end
