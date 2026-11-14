class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_estudante

  private

  # estudante autenticado na sessão (nil quando ninguém está logado)
  def current_estudante
    return @current_estudante if defined?(@current_estudante)

    @current_estudante = Estudante.find_by(id: session[:estudante_id])
  end
end