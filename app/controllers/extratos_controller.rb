class ExtratosController < ApplicationController
  before_action :require_estudante!

  def recargas
    @recargas = filtrar(current_estudante.recargas)
    @total    = @recargas.sum(&:valor).round(2)
  end

  def refeicoes
    @refeicoes = filtrar(current_estudante.refeicoes)
    @total     = @refeicoes.sum(&:valor).round(2)
  end

  def detalhe_recarga
    @recarga = current_estudante.recargas.find(params[:id])
  end

  def painel
    @aba              = params[:aba].presence || "recargas"
    @recargas         = current_estudante.recargas.order(:data)
    @refeicoes        = current_estudante.refeicoes.order(:data)
    @total_recargas   = @recargas.sum(&:valor).round(2)
    @total_refeicoes  = @refeicoes.sum(&:valor).round(2)
  end

  private

  def filtrar(scope)
    scope = scope.order(:data)
    if params[:inicio].present?
      ini = parse_date(params[:inicio])
      scope = scope.where("data >= ?", ini) if ini
    end
    if params[:fim].present?
      fim = parse_date(params[:fim])
      scope = scope.where("data <= ?", fim) if fim
    end
    scope
  end

  def parse_date(str)
    Date.strptime(str, "%d/%m/%Y")
  rescue ArgumentError
    nil
  end
end
