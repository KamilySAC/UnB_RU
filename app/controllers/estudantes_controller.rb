# Cadastro de estudante: GET /cadastro (formulário) e POST /cadastro (criação da conta).
class EstudantesController < ApplicationController
  def new
    @cadastro = CadastroEstudante.new(matricula: "", nome: "", senha: "", confirmacao_senha: "")
  end

  def create
    dados = cadastro_params
    @cadastro = CadastroEstudante.new(
      matricula: dados[:matricula],
      nome: dados[:nome],
      senha: dados[:senha],
      confirmacao_senha: dados[:confirmacao_senha]
    )

    if @cadastro.call
      reset_session
      session[:estudante_id] = @cadastro.estudante.id
      redirect_to root_path, notice: CadastroEstudante::MSG_SUCESSO
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def cadastro_params
    params.fetch(:estudante, {}).permit(:matricula, :nome, :senha, :confirmacao_senha)
  end
end
