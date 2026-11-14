# Página inicial do estudante.
class HomeController < ApplicationController
  def index
    @estudante = current_estudante
  end
end
