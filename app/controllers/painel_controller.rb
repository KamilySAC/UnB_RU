# telas do aplicativo liberadas depois do login do funcionário
class PainelController < ApplicationController
  before_action :exigir_login

  # GET /ponto-de-acesso
  def configuracao_ponto; end

  # GET /terminal-de-validacao
  def terminal_validacao; end

  # GET /historico-local: lista as catracas e leva ao histórico do João
  def historico_local
    @catracas = Catraca.includes(:restaurante).order(:nome)
  end
end