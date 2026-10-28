class SessionsController < ApplicationController
  def new; end

  def create
    estudante = Estudante.find_by(email: params[:email])
    if estudante
      session[:estudante_id] = estudante.id
      redirect_to dashboard_path
    else
      flash.now[:alert] = 'Estudante não encontrado'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.clear
    redirect_to login_path
  end
end
