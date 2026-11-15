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

  # verifica se o estudante é isento
  def isento?
    grupo == "Grupo I"
  end

  # retorna a tarifa de acordo com o turno
  def tarifa_para(turno)
    BigDecimal((TARIFAS.dig(grupo, turno) || 0.0).to_s)
  end

  # adiciona uma recarga ao saldo do estudante
  def adicionar_recarga(recarga)
    transaction do
      recarga.estudante = self
      recarga.save!
      update!(saldo: (saldo + recarga.valor).round(2))
    end
    recarga
  end
end