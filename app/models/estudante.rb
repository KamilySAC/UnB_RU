class Estudante < ApplicationRecord
  # grupos tarifários
  GRUPOS = [ "Grupo I", "Grupo II", "Grupo III", "Grupo IV" ].freeze # não altera em tempo de execução

  # grupos de tarifas, hash
  TARIFAS = {
    "Grupo I" => { "Café da manhã" => 0.00, "Almoço" => 0.00, "Jantar" => 0.00 },
    "Grupo II" => { "Café da manhã" => 2.00, "Almoço" => 4.50, "Jantar" => 4.50 },
    "Grupo III" => { "Café da manhã" => 7.05, "Almoço" => 15.20, "Jantar" => 15.20 },
    "Grupo IV" => { "Café da manhã" => 1.50, "Almoço" => 2.50, "Jantar" => 2.50 }
  }.freeze

  # relação: um estudante tem muitos registros na catraca: um para muitos
  has_many :acessos_catraca, class_name: "AcessoCatraca", dependent: :destroy
  has_many :recargas, dependent: :destroy
  has_many :refeicoes, class_name: "Refeicao", dependent: :destroy

  # validaçoes dos campos

  validates :nome, presence: true # nome é obrigatório (não pode ser nulo ou vazio)
  validates :matricula, presence: true, uniqueness: true # não permite duas contas com a mesma matricula
  validates :grupo, inclusion: { in: GRUPOS } # o grupo precisa ser dentro dos 4 grupos definidos
  validates :saldo, numericality: { greater_than_or_equal_to: 0.00 } # saldo não pode ser negativo


  # booleano retorna true se o grupo for I,
  def isento?
    grupo == "Grupo I"
  end

  # retorna a tarifa que este estudante deve pagar de acordo com o turno
  # recebe o nome do turno e busca o valor em tarifas
  def tarifa_para(turno)
    BigDecimal((TARIFAS.dig(grupo, turno) || 0.0).to_s)
  end
end
