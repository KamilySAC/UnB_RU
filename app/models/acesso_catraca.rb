# Responsável por validar a leitura de identificação na catraca do RU,
# controlar o estado de liberação e bloqueio, aplicar a regra de anti-passback,
# gerenciar o timeout de 5 segundos e efetuar o débito no giro físico.
class AcessoCatraca < ApplicationRecord
  # referencia a tabela do banco ao ruby
  self.table_name = "acessos_catraca"

  # lista de turno do RU
  TURNOS = [ "Café da manhã", "Almoço", "Jantar" ]

  # refatoração: adicionado estados positivos da catrac
  STATUS_CONCLUIDOS = [ "registrado", "isento" ].freeze

  # tempo limite de timeout antes da trava de catraca
  TIMEOUT_SEG = 5

  # relação: cada acesso pertence a uma pessoa
  # optional: caso não seja estudante.
  belongs_to :estudante, optional: true

  # validações básicas de preenchimento
  validates :turno, inclusion: { in: TURNOS }
  validates :data, presence: true # presence = obrigatóriedade


  # Processa a leitura da identificação (QR Code/matrícula) no sensor da catraca
  # e avalia todas as regras de bloqueio antes de autorizar a passagem.
  #
  # Insere um novo registro em +acessos_catraca+ sem alterar o saldo do estudante até o giro físico.
  #
  # @param identificacao [String] matrícula lida pelo leitor da catraca.
  # @param turno [String] turno da refeição ("Café da manhã", "Almoço" ou "Jantar").
  # @param data [Date] data da leitura (padrão: +Date.current+).
  # @param tarifa_customizada [Numeric, nil] tarifa opcional para sobrescrever a tabela padrão.
  # @return [AcessoCatraca] registro persistido com +status_catraca+ "liberada" (caso aprovado)
  #   ou "bloqueada" (caso negado por usuário inexistente, anti-passback ou saldo insuficiente).
  def self.ler_identificacao(identificacao:, turno:, data: Date.current, tarifa_customizada: nil)
    # converte o identificador lido no sensor para string
    matricula = identificacao.to_s

    # busca o estudante pela matrícula lida no sensor
    estudante = Estudante.find_by(matricula: matricula)

    # se não encontrar o estudante no banco, bloqueia imediatamente a passagem
    return registrar_bloqueio(identificacao: matricula, turno: turno, data: data, mensagem: "Usuário não encontrado") unless estudante

    # descobre o valor da tarifa considerando grupo/turno ou tarifa customizada
    tarifa = calcular_tarifa(estudante, turno, tarifa_customizada)

    # verifica se há alguma regra impeditiva (anti-passback ou saldo insuficiente)
    erro = motivo_bloqueio(estudante, turno, data, tarifa)

    # se houve algum motivo de bloqueio, grava o acesso negado e exibe no visor
    return registrar_bloqueio(estudante: estudante, identificacao: matricula, turno: turno, data: data, mensagem: erro) if erro

    # caminho feliz: registra a liberação provisória e aguarda o giro físico
    registrar_liberacao(estudante: estudante, turno: turno, data: data, tarifa: tarifa)
  end

  # Confirma o giro físico da catraca pelo estudante, concluindo o acesso
  # e efetuando o débito da tarifa no saldo (quando pagante).
  #
  # Executa transação em +acessos_catraca+ e +estudantes+, debitando +valor_debitado+
  # do +saldo+ quando pagante e atualizando +status_acesso+ para "registrado" ou "isento".
  #
  # @return [Boolean] +true+ quando a atualização do acesso é concluída com sucesso;
  #   lança +RuntimeError+ ("Catraca não está liberada") caso a catraca não esteja aguardando giro.
  def registrar_giro!
    raise "Catraca não está liberada" unless aguardando_giro?

    transaction do
      isento? ? concluir_giro_isento! : concluir_giro_pagante!
    end


    # só é permitido o giro se o acesso estiver com o status de catraca liberada e aguardando giro
    # raise "Catraca não está liberada" unless status_catraca == "liberada" && status_acesso == "aguardando_giro"
    #
    # transaction garante que se der errado no meio do caminho ele volta o que fez
    # transaction do
    #   if isento?
    #     # grupo I passa sem debitar, apenas atualiza o status do acesso
    #     update!(
    #       valor_debitado: 0.0,
    #       status_acesso: "isento",
    #       mensagem_visor: "Acesso Liberado - Isento"
    #     )
    #   else
    #     # Estudante pagantes: debita a tarifa do saldo e atualiza o status do acesso
    #     novo_saldo = (estudante.saldo - valor_debitado).round(2)
    #     estudante.update!(saldo: novo_saldo)
    #
    #     # marca acesso como concluído
    #     update!(
    #       status_acesso: "registrado",
    #       mensagem_visor: "Refeição efetuada com sucesso"
    #     )
    #   end
    # end
  end

  # Verifica se o tempo limite de 5 segundos sem giro físico foi atingido
  # e trava novamente a catraca sem debitar o saldo do estudante.
  #
  # Quando o timeout ocorre, atualiza +status_catraca+ para "bloqueada" e +status_acesso+
  # para "cancelado" mantendo o saldo intacto.
  #
  # @param segundos_decorridos [Numeric] quantidade de segundos passados desde a liberação.
  # @return [Boolean] +true+ se o acesso expirou e foi cancelado; +false+ se a catraca
  #   não estava aguardando giro ou se o tempo decorrido for menor que +TIMEOUT_SEG+.
  def verificar_timeout!(segundos_decorridos)
    return false unless aguardando_giro? && segundos_decorridos >= TIMEOUT_SEG

    update!(
      valor_debitado: 0.0,
      status_catraca: "bloqueada",
      status_acesso: "cancelado",
      mensagem_visor: "Tempo esgotado - Catraca bloqueada"
    )
    true
  end

  # Verifica se a catraca encontra-se liberada e aguardando o acionamento do sensor de giro.
  #
  # Sem efeitos colaterais (apenas leitura em memória).
  #
  # @return [Boolean] +true+ se +status_catraca+ for "liberada" e +status_acesso+ for "aguardando_giro", +false+ caso contrário.
  def aguardando_giro?
    # retorna verdadeiro apenas quando a catraca está liberada esperando a passagem física
    status_catraca == "liberada" && status_acesso == "aguardando_giro"
  end


  # abre o bloco de metodos auxiliares privados da classe
  class << self
    private

      # usa tarifa customizada ou busca na tabela do grupo/turno do aluno
      def calcular_tarifa(estudante, turno, tarifa_customizada)
        tarifa_customizada ? BigDecimal(tarifa_customizada.to_s) : estudante.tarifa_para(turno)
      end

      # verifica as regras de bloqueio em ordem e devolve a mensagem de erro
      def motivo_bloqueio(estudante, turno, data, tarifa)
        # regra anti-passback: não pode repetir refeição
        return "Refeição já utilizada neste turno" if refeicao_ja_realizada?(estudante, turno, data)

        # regra de saldo: bloqueia se não for isento e o saldo for menor que a tarifa
        "Saldo insuficiente" if saldo_insuficiente?(estudante, tarifa)
      end

      # consulta no banco se o estudante já possui acesso concluído hoje no turno
      def refeicao_ja_realizada?(estudante, turno, data)
        where(
          estudante_id: estudante.id,
          turno: turno,
          data: data,
          status_acesso: STATUS_CONCLUIDOS
        ).exists?
      end

      # retorna true quando o estudante é pagante e não tem saldo suficiente
      def saldo_insuficiente?(estudante, tarifa)
        !estudante.isento? && estudante.saldo < tarifa
      end

      # cria no banco um registro de tentativa bloqueada com o motivo no visor
      def registrar_bloqueio(identificacao:, turno:, data:, mensagem:, estudante: nil)
        create!(
          estudante: estudante,
          identificacao_lida: identificacao,
          turno: turno,
          data: data,
          mensagem_visor: mensagem,
          status_catraca: "bloqueada",
          status_acesso: "negado"
        )
      end

      def registrar_liberacao(estudante:, turno:, data:, tarifa:)
        create!(
          estudante: estudante,
          identificacao_lida: estudante.matricula,
          turno: turno,
          data: data,
          valor_debitado: tarifa,
          isento: estudante.isento?,
          status_catraca: "liberada",
          status_acesso: "aguardando_giro",
          mensagem_visor: "Catraca liberada"
        )
      end
  end

  # métodos auxiliares privados de instância - usados por registrar_giro!
  private

  # finaliza o giro para estudante do grupo I sem descontar nada do saldo
  def concluir_giro_isento!
    update!(
      valor_debitado: 0.00,
      status_acesso: "isento",
      mensagem_visor: "Acesso Liberado - Isento"
    )
  end

  # finaliza o giro para estudante pagante descontando a tarifa do saldo
  def concluir_giro_pagante!
    novo_saldo = (estudante.saldo - valor_debitado).round(2)

    estudante.update!(saldo: novo_saldo)
    update!(
      status_acesso: "registrado",
      mensagem_visor: "Refeição efetuada com sucesso"
    )
  end
end
