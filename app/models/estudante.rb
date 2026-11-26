# Representa o discente ou usuário cadastrado no Restaurante Universitário,
# armazenando seu grupo tarifário, saldo disponível, credenciais de acesso
# e relacionamentos com passagens na catraca, recargas e refeições.
class Estudante < ApplicationRecord
  # grupos tarifários
  GRUPOS = [ "Grupo I", "Grupo II", "Grupo III", "Grupo IV" ].freeze

  # grupos de tarifas
  TARIFAS = {
    "Grupo I" => { "Café da manhã" => 0.00, "Almoço" => 0.00, "Jantar" => 0.00 },
    "Grupo II" => { "Café da manhã" => 2.00, "Almoço" => 4.50, "Jantar" => 4.50 },
    "Grupo III" => { "Café da manhã" => 7.05, "Almoço" => 15.20, "Jantar" => 15.20 },
    "Grupo IV" => { "Café da manhã" => 1.50, "Almoço" => 2.50, "Jantar" => 2.50 }
  }.freeze

  # senha criptografada usada no cadastro e no login
  has_secure_password validations: false

  # relacionamentos
  has_many :acessos_catraca, class_name: "AcessoCatraca", dependent: :destroy
  has_many :recargas, dependent: :destroy
  has_many :refeicoes, class_name: "Refeicao", dependent: :destroy

  # validações
  validates :nome, presence: true
  validates :matricula, presence: true, uniqueness: true
  validates :grupo, inclusion: { in: GRUPOS }
  validates :saldo, numericality: { greater_than_or_equal_to: 0.00 }

  # Verifica se o estudante pertence ao Grupo I (isenção tarifária integral).
  #
  # Sem efeitos colaterais (apenas leitura em memória).
  #
  # @return [Boolean] +true+ caso +grupo+ seja +"Grupo I"+, +false+ para os demais grupos pagantes.
  def isento?
    grupo == "Grupo I"
  end

  # Calcula o valor da tarifa aplicável ao estudante de acordo com o turno da refeição.
  #
  # Sem efeitos colaterais (consulta apenas a constante +TARIFAS+ em memória).
  #
  # @param turno [String] nome do turno (+"Café da manhã"+, +"Almoço"+ ou +"Jantar"+).
  # @return [BigDecimal] valor monetário correspondente ao grupo e turno (ou +0.0+ caso o turno não exista na tabela).
  def tarifa_para(turno)
    BigDecimal((TARIFAS.dig(grupo, turno) || 0.0).to_s)
  end

  # Persiste uma nova recarga associada ao estudante e soma o valor ao saldo atual.
  #
  # Abre transação inserindo o registro em +recargas+ e somando o valor na coluna +saldo+ em +estudantes+.
  #
  # @param recarga [Recarga] instância de recarga a ser salva e creditada.
  # @return [Recarga] a própria instância de recarga persistida;
  #   lança +ActiveRecord::RecordInvalid+ caso a recarga ou a atualização de saldo seja inválida.
  def adicionar_recarga(recarga)
    transaction do
      recarga.estudante = self
      recarga.save!
      update!(saldo: (saldo + recarga.valor).round(2))
    end
    recarga
  end
end
