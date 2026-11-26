# Gerencia a tela do Terminal de Validação operada pelo funcionário do RU,
# permitindo ler a matrícula do estudante, confirmar o giro da catraca
# e simular o cancelamento por timeout de 5 segundos.
class TerminalValidacaoController < ApplicationController
  before_action :exigir_login

  # Exibe o terminal de validação com o formulário de leitura, o visor
  # da última operação e as leituras registradas na data atual.
  #
  # @return [void] renderiza a view +terminal_validacao/show+.
  def show
    @catracas = Catraca.includes(:restaurante).order(:nome)
    @catraca = buscar_catraca
    @turno = turno_selecionado
    @acesso_atual = AcessoCatraca.includes(:estudante).find_by(id: params[:acesso_id])
    @acessos_hoje = AcessoCatraca.includes(:estudante).where(data: Date.current).order(id: :desc)
  end

  # Processa a leitura da matrícula no terminal e atualiza o visor da catraca.
  #
  # @return [void] redireciona para +terminal_validacao_path+ exibindo no flash
  #   o resultado da validação ou o erro de campo obrigatório.
  def validar
    identificacao = params[:identificacao].to_s.strip
    turno = turno_selecionado
    catraca = buscar_catraca

    if identificacao.blank?
      return redirecionar_terminal(catraca: catraca, turno: turno, alert: "Informe a matrícula do estudante.")
    end

    acesso = OperacaoTerminalCatraca.ler(identificacao: identificacao, turno: turno, catraca: catraca)
    flash_tipo = acesso.aguardando_giro? ? :notice : :alert

    redirecionar_terminal(acesso: acesso, catraca: catraca, turno: turno, flash_tipo => acesso.mensagem_visor)
  end

  # Confirma o giro físico da catraca para um acesso liberado, efetivando
  # o débito no saldo e o registro da refeição/passagem.
  #
  # @return [void] redireciona para +terminal_validacao_path+ com mensagem de confirmação
  #   ou alerta caso a catraca não esteja liberada.
  def registrar_giro
    acesso = AcessoCatraca.find(params[:id])
    catraca = buscar_catraca

    unless acesso.aguardando_giro?
      return redirecionar_terminal(acesso: acesso, catraca: catraca, alert: "Catraca não está liberada.")
    end

    OperacaoTerminalCatraca.confirmar_giro(acesso, catraca: catraca)
    redirecionar_terminal(acesso: acesso, catraca: catraca, notice: acesso.mensagem_visor)
  end

  # Aplica o cancelamento por timeout de 5 segundos quando o estudante não
  # aciona o giro da catraca dentro do tempo limite.
  #
  # @return [void] redireciona para +terminal_validacao_path+ com o aviso no visor
  #   ou alerta caso o acesso não esteja aguardando giro.
  def timeout
    acesso = AcessoCatraca.find(params[:id])
    catraca = buscar_catraca
    cancelado = OperacaoTerminalCatraca.cancelar_por_timeout(acesso, catraca: catraca)
    mensagem = cancelado ? acesso.mensagem_visor : "Catraca não está aguardando giro."

    redirecionar_terminal(acesso: acesso, catraca: catraca, alert: mensagem)
  end

  private

  def redirecionar_terminal(acesso: nil, catraca: nil, turno: nil, **flash_opcoes)
    redirect_to terminal_validacao_path(
      acesso_id: acesso&.id,
      catraca_id: catraca&.id,
      turno: turno || acesso&.turno
    ), **flash_opcoes
  end

  def buscar_catraca
    Catraca.find_by(id: params[:catraca_id])
  end

  def turno_selecionado
    AcessoCatraca::TURNOS.include?(params[:turno]) ? params[:turno] : "Almoço"
  end
end
