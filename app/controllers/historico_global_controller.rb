# histórico global de acessos do campus: só administrador
class HistoricoGlobalController < ApplicationController
  before_action :exigir_administrador

  # GET /historico-global?restaurante_id=&catraca_id=&agrupar=restaurante|catraca
  def index
    restaurante = buscar(Restaurante, params[:restaurante_id])
    catraca = buscar(Catraca, params[:catraca_id])
    return head :bad_request if restaurante == :invalido || catraca == :invalido
    return head :bad_request if params[:agrupar].present? && !HistoricoGlobal::AGRUPAMENTOS.include?(params[:agrupar].to_s)

    @historico = HistoricoGlobal.new(restaurante: restaurante, catraca: catraca, agrupar: params[:agrupar])
  end

  private

  # nil se o filtro não foi enviado; :invalido se o id não existe
  def buscar(modelo, id)
    return nil if id.blank?

    modelo.find_by(id: id.to_s) || :invalido
  end
end
