# login e logout do funcionário
class FuncionarioSessionsController < ApplicationController
  # limita tentativas de login (dificulta força bruta)
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to login_funcionario_path, alert: "Muitas tentativas. Aguarde alguns minutos." }

  # GET /funcionario/login
  def new
    return redirect_to(configuracao_ponto_path) if funcionario_autenticado?

    @identificador = ""
    @erros = []
  end

  # POST /funcionario/login
  def create
    @identificador = params[:identificador].to_s.strip
    senha = params[:senha].to_s

    # campo vazio: informa qual está faltando e não tenta autenticar
    @erros = []
    @erros << "A matrícula ou usuário é obrigatório." if @identificador.empty?
    @erros << "A senha é obrigatória." if senha.empty?
    return render_erros if @erros.any?

    funcionario = Funcionario.autenticar(@identificador, senha)

    if funcionario
      iniciar_sessao(funcionario)
      redirect_to configuracao_ponto_path
    else
      # mesma mensagem para identificador inexistente e senha errada
      @erros << "Credenciais inválidas."
      render_erros
    end
  end

  # DELETE /funcionario/logout
  def destroy
    encerrar_sessao
    redirect_to login_funcionario_path, notice: "Sessão encerrada.", status: :see_other
  end

  private

  def render_erros
    render :new, status: :unprocessable_content
  end
end