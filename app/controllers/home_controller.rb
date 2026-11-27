# Página inicial do site
class HomeController < ApplicationController
  def index
    redirect_to dashboard_path if estudante_logado?
  end
end
