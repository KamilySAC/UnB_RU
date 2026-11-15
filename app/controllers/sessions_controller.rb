# Login do estudante com matrícula e senha (as mesmas informadas em /cadastro).
class SessionsController < ApplicationController
  MSG_CREDENCIAIS_INVALIDAS = "Matrícula ou senha inválidas".freeze

  def new
    redirect_to dashboard_path if estudante_logado?
  end

  def create
    estudante = Estudante.find_by(matricula: params[:matricula].to_s.strip)

    if estudante&.password_digest.present? && estudante.authenticate(params[:senha].to_s)
      reset_session
      session[:estudante_id] = estudante.id
      redirect_to dashboard_path
    else
      flash.now[:alert] = MSG_CREDENCIAIS_INVALIDAS
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end
end
