# controla a sessão do funcionário (fiscal ou administrador)
module Autenticacao
  extend ActiveSupport::Concern

  included do
    helper_method :funcionario_atual, :funcionario_autenticado?
  end

  private

  # funcionário da sessão, ou nil se ninguém estiver autenticado
  def funcionario_atual
    return @funcionario_atual if defined?(@funcionario_atual)

    @funcionario_atual = Funcionario.find_by(id: session[:funcionario_id])
  end

  def funcionario_autenticado?
    funcionario_atual.present?
  end

  # before_action: manda para o login quem não está autenticado
  def exigir_login
    return if funcionario_autenticado?

    redirect_to login_funcionario_path, alert: "Faça login para continuar."
  end

  # before_action: só administrador passa (vai servir para o histórico global)
  def exigir_administrador
    exigir_login
    return if performed?
    return if funcionario_atual.administrador?

    redirect_to historico_local_path, alert: "Você não tem permissão para acessar esta tela."
  end

  def iniciar_sessao(funcionario)
    reset_session # troca o id da sessão (evita fixação de sessão)
    session[:funcionario_id] = funcionario.id
    @funcionario_atual = funcionario
  end

  def encerrar_sessao
    reset_session
    @funcionario_atual = nil
  end
end