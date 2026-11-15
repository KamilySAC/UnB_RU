class ApplicationController < ActionController::Base
  helper_method :current_estudante, :estudante_logado?
  
  include Autenticacao
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # estudante autenticado na sessão (nil quando ninguém está logado)
  def current_estudante
    return @current_estudante if defined?(@current_estudante)

    @current_estudante = Estudante.find_by(id: session[:estudante_id])
  end

  def estudante_logado?
    current_estudante.present?
  end

  def require_estudante!
    redirect_to login_path, alert: "Faça login primeiro" unless estudante_logado?
  end
end