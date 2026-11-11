class ApplicationController < ActionController::Base
  helper_method :current_estudante, :estudante_logado?

  private

  def current_estudante
    @current_estudante ||= Estudante.find_by(id: session[:estudante_id])
  end

  def estudante_logado?
    current_estudante.present?
  end

  def require_estudante!
    redirect_to login_path, alert: "Faça login primeiro" unless estudante_logado?
  end
end
