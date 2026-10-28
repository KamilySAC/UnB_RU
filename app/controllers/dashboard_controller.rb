class DashboardController < ApplicationController
  before_action :require_estudante!

  def show
    @estudante = current_estudante
  end
end
