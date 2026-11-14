class AcessoCatraca < ApplicationRecord
  # referencia a tabela do banco ao ruby
  self.table_name = "acessos_catraca"

  # lista de turno do RU
  TURNOS = [ "Café da manhã", "Almoço", "Jantar" ]

  # tempo limite de timeout antes da trava de catraca
  TIMEOUT_SEG = 5

  # relação: cada acesso pertence a uma pessoa
  # optional: caso não seja estudante.
  belongs_to :estudante, optional: true

  # validações básicas de preenchimento
  validates :turno, inclusion: { in: TURNOS }
  validates :data, presence: true # presence = obrigatóriedade


  # funçao para leitura de catraca, avalia todas as regras de bloqueio antes de autorizar a passagem
  def self.ler_identificacao(identificacao:, turno:, data: Date.current, tarifa_customizada: nil)
    # busca o estudante pela matricula lido no sensor
    estudante = Estudante.find_by(matricula: identificacao.to_s)

    # primeira regra: usuário não existe na base de dados, se não existe, bloqueia
    if estudante.nil?
      return create!(
        identificacao_lida: identificacao.to_s,
        turno: turno,
        data: data,
        status_catraca: "bloqueada",
        status_acesso: "negado",
        mensagem_visor: "Usuário não encontrado"
      )
    end

    # segunda regra: bloqueio de dupla entrada no mesmo turno, verifica se o estudante ja completou uma refeição
    ja_usou = where(
      estudante_id: estudante.id,
      turno: turno,
      data: data,
      status_acesso: [ "registrado", "isento" ]
    ).exists?

    if ja_usou
      return create!(
        estudante: estudante,
        identificacao_lida: estudante.matricula,
        turno: turno,
        data: data,
        status_catraca: "bloqueada",
        status_acesso: "negado",
        mensagem_visor: "Refeição já utilizada neste turno"
      )
    end

    # calcula quanto custa a refeição para o referido discente
    tarifa = tarifa_customizada ? BigDecimal(tarifa_customizada.to_s) : estudante.tarifa_para(turno)


    # terceira regra: verificação de saldo para não isentos
    if !estudante.isento? && estudante.saldo < tarifa
      return create!(
        estudante: estudante,
        identificacao_lida: estudante.matricula,
        turno: turno,
        data: data,
        status_catraca: "bloqueada",
        status_acesso: "negado",
        mensagem_visor: "Saldo insuficiente"
      )
    end

    # quarta regra: caminho feliz - autorização provisória
    # destrava a catraca e aguarda o discente girar a catraca, o saldo aqui não é debitado, a catraca fica aguardando giro.


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

  # Função 2
  # método responsável por registrar o giro na catraca
  # a (!) indica que indica alteração de dados criticos - saldo

  def registrar_giro!
    # só é permitido o giro se o acesso estiver com o status de catraca liberada e aguardando giro
    raise "Catraca não está liberada" unless status_catraca == "liberada" && status_acesso == "aguardando_giro"

    # transaction garante que se der errado no meio do caminho ele volta o que fez
    transaction do
      if isento?
        # grupo I passa sem debitar, apenas atualiza o status do acesso
        update!(
          valor_debitado: 0.0,
          status_acesso: "isento",
          mensagem_visor: "Acesso Liberado - Isento"
        )
      else
        # Estudante pagantes: debita a tarifa do saldo e atualiza o status do acesso
        novo_saldo = (estudante.saldo - valor_debitado).round(2)
        estudante.update!(saldo: novo_saldo)

        # marca acesso como concluído
        update!(
          status_acesso: "registrado",
          mensagem_visor: "Refeição efetuada com sucesso"
        )
      end
    end
  end

  # timeout de seg sem giro
  def verificar_timeout!(segundos_decorridos)
    return false unless status_catraca == "liberada" && status_acesso == "aguardando_giro"
    return false if segundos_decorridos < TIMEOUT_SEG

    update!(
      valor_debitado: 0.0,
      status_catraca: "bloqueada",
      status_acesso: "cancelado",
      mensagem_visor: "Tempo esgotado - Catraca bloqueada"
    )
    true
  end
end
