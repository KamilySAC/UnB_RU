# Orquestra a operação do terminal de validação da catraca, integrando a máquina
# de estados de +AcessoCatraca+ com o histórico de refeições do estudante (+Refeicao+)
# e os registros operacionais das catracas físicas (+Acesso+).
class OperacaoTerminalCatraca
  # Modo de validação registrado nos acessos da catraca física.
  MODO_VALIDACAO = "Terminal".freeze

  # Nome padrão do restaurante quando nenhuma catraca física está vinculada.
  RESTAURANTE_PADRAO = "RU Darcy Ribeiro".freeze

  # Realiza a leitura da identificação do estudante na catraca e registra bloqueios
  # no histórico operacional da catraca física quando informada.
  #
  # @param identificacao [String] matrícula informada no terminal.
  # @param turno [String] turno da refeição (+"Café da manhã"+, +"Almoço"+ ou +"Jantar"+).
  # @param catraca [Catraca, nil] catraca física selecionada pelo operador.
  # @return [AcessoCatraca] registro persistido da tentativa de validação.
  def self.ler(identificacao:, turno:, catraca: nil)
    acesso_catraca = AcessoCatraca.ler_identificacao(identificacao: identificacao, turno: turno)

    if catraca && acesso_catraca.status_acesso == "negado"
      registrar_acesso_catraca(
        catraca,
        acesso_catraca,
        status: :bloqueado,
        tarifa: 0,
        motivo: acesso_catraca.mensagem_visor
      )
    end

    acesso_catraca
  end

  # Confirma o giro físico da catraca, debitando o saldo do estudante, criando
  # a refeição no extrato estudantil e registrando a passagem na catraca física.
  #
  # @param acesso_catraca [AcessoCatraca] acesso previamente liberado aguardando giro.
  # @param catraca [Catraca, nil] catraca física selecionada pelo operador.
  # @return [AcessoCatraca] o registro de acesso atualizado após o giro.
  def self.confirmar_giro(acesso_catraca, catraca: nil)
    ActiveRecord::Base.transaction do
      acesso_catraca.registrar_giro!
      registrar_refeicao(acesso_catraca, catraca)
      if catraca
        registrar_acesso_catraca(catraca, acesso_catraca, status: :liberado, tarifa: acesso_catraca.valor_debitado)
      end
    end

    acesso_catraca
  end

  # Cancela uma liberação por timeout de 5 segundos sem giro físico e registra
  # o cancelamento no histórico operacional da catraca quando vinculada.
  #
  # @param acesso_catraca [AcessoCatraca] acesso liberado no terminal.
  # @param catraca [Catraca, nil] catraca física selecionada pelo operador.
  # @return [Boolean] +true+ se foi cancelado por timeout; +false+ caso contrário.
  def self.cancelar_por_timeout(acesso_catraca, catraca: nil)
    cancelado = false

    ActiveRecord::Base.transaction do
      cancelado = acesso_catraca.verificar_timeout!(AcessoCatraca::TIMEOUT_SEG)
      registrar_acesso_catraca(catraca, acesso_catraca, status: :cancelado, tarifa: 0) if cancelado && catraca
    end

    cancelado
  end

  class << self
    private

    def registrar_refeicao(acesso_catraca, catraca)
      return unless acesso_catraca.estudante && acesso_catraca.valor_debitado.positive?

      Refeicao.create!(
        estudante: acesso_catraca.estudante,
        restaurante: nome_restaurante(catraca),
        valor: acesso_catraca.valor_debitado,
        data: acesso_catraca.data
      )
    end

    def nome_restaurante(catraca)
      catraca ? catraca.restaurante.nome : RESTAURANTE_PADRAO
    end

    def registrar_acesso_catraca(catraca, acesso_catraca, status:, tarifa:, motivo: nil)
      catraca.acessos.create!(
        matricula_discente: acesso_catraca.identificacao_lida,
        turno: acesso_catraca.turno,
        modo_validacao: MODO_VALIDACAO,
        tarifa: tarifa,
        status_acesso: status,
        status_catraca: catraca.status,
        motivo_negativa: motivo,
        ocorrido_em: Time.current
      )
    end
  end
end
