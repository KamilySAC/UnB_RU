class AcessosController < ApplicationController
  before_action :set_catraca

  def index
    base = @catraca.acessos
    acessos_de_hoje = base.where(ocorrido_em: Time.zone.now.all_day)

    @giros = acessos_de_hoje.liberado.count
    @total_debito = acessos_de_hoje.liberado.sum(:tarifa)

    @acessos = base.order(ocorrido_em: :desc)
    if params[:data].present?
      begin
        data = Date.iso8601(params[:data])
      rescue Date::Error
        return head :bad_request
      end

      @acessos = @acessos.where(ocorrido_em: data.all_day)
    end

    if params[:status].present?
      return head :bad_request unless Acesso.status_acessos.key?(params[:status])

      @acessos = @acessos.where(status_acesso: params[:status])
    end
    @acessos = @acessos.where(modo_validacao: params[:modo]) if params[:modo].present?
    @acessos = @acessos.where(turno: params[:turno]) if params[:turno].present?
  end

  def new
    @acesso = @catraca.acessos.new(
      ocorrido_em: Time.current,
      status_acesso: :liberado,
      status_catraca: @catraca.status
    )
  end

  def create
    attributes = acesso_params
    unless Acesso.status_acessos.key?(attributes[:status_acesso]) &&
          Acesso.status_catracas.key?(attributes[:status_catraca])
      @acesso = @catraca.acessos.new(attributes.except(:status_acesso, :status_catraca))
      @acesso.errors.add(:base, "Selecione um status válido para o acesso e a catraca.")
      return render :new, status: :unprocessable_entity
    end

    @acesso = @catraca.acessos.build(attributes)
    if @acesso.save
      redirect_to catraca_acessos_path(@catraca), notice: "Acesso registrado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_catraca
    @catraca = Catraca.find(params[:catraca_id])
  end

  def acesso_params
    params.require(:acesso).permit(
      :matricula_discente,
      :turno,
      :modo_validacao,
      :tarifa,
      :status_acesso,
      :status_catraca,
      :motivo_negativa,
      :ocorrido_em
    )
  end
end