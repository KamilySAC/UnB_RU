# frozen_string_literal: true

# Provides read-only views over a student's history: recharges and meals,
# with optional date filtering and totals.
class ExtratosController < ApplicationController
  before_action :require_estudante!

  # @return [void]
  def recargas
    @recargas = filtrar(current_estudante.recargas)
    @total    = total_de(@recargas)
  end

  # @return [void]
  def refeicoes
    @refeicoes = filtrar(current_estudante.refeicoes)
    @total     = total_de(@refeicoes)
  end

  # @return [void]
  def detalhe_recarga
    @recarga = current_estudante.recargas.find(params[:id])
  end

  # Renders the tabbed spending panel (recargas / refeições).
  #
  # @return [void]
  def painel
    @aba             = params[:aba].presence || "recargas"
    @recargas        = current_estudante.recargas.order(:data)
    @refeicoes       = current_estudante.refeicoes.order(:data)
    @total_recargas  = total_de(@recargas)
    @total_refeicoes = total_de(@refeicoes)
  end

  private

  # @param scope [ActiveRecord::Relation]
  # @return [ActiveRecord::Relation] filtered by +params[:inicio]+ / +params[:fim]+
  def filtrar(scope)
    scope = scope.order(:data)
    ini = parse_date(params[:inicio])
    fim = parse_date(params[:fim])
    scope = scope.where("data >= ?", ini) if ini
    scope = scope.where("data <= ?", fim) if fim
    scope
  end

  # @param scope [ActiveRecord::Relation]
  # @return [Float] sum of +valor+ rounded to 2 decimals
  def total_de(scope)
    scope.sum(&:valor).round(2)
  end

  # @param str [String, nil] date in "dd/mm/yyyy"
  # @return [Date, nil] parsed date or nil when blank/invalid
  def parse_date(str)
    return nil if str.blank?
    Date.strptime(str, "%d/%m/%Y")
  rescue ArgumentError
    nil
  end
end
