# frozen_string_literal: true

# Represents a student (estudante) using the university restaurant system.
#
# A student belongs to a tariff group (Grupo I–IV) that determines the price
# paid per meal shift, and holds a balance (saldo) topped up via recharges.
#
# @example Fetching a student's lunch price
#   estudante.tarifa_para("Almoço") #=> 0.0e0 for Grupo I
class Estudante < ApplicationRecord
  # Tariff groups recognized by the system.
  GRUPOS = [ "Grupo I", "Grupo II", "Grupo III", "Grupo IV" ].freeze

  # Per-shift prices (in BRL) for each tariff group.
  #
  # @return [Hash{String => Hash{String => Float}}]
  TARIFAS = {
    "Grupo I"   => { "Café da manhã" => 0.00, "Almoço" => 0.00, "Jantar" => 0.00 },
    "Grupo II"  => { "Café da manhã" => 2.00, "Almoço" => 4.50, "Jantar" => 4.50 },
    "Grupo III" => { "Café da manhã" => 7.05, "Almoço" => 15.20, "Jantar" => 15.20 },
    "Grupo IV"  => { "Café da manhã" => 1.50, "Almoço" => 2.50, "Jantar" => 2.50 }
  }.freeze

  has_secure_password validations: false

  has_many :acessos_catraca, class_name: "AcessoCatraca", dependent: :destroy
  has_many :recargas, dependent: :destroy
  has_many :refeicoes, class_name: "Refeicao", dependent: :destroy

  validates :nome, presence: true
  validates :matricula, presence: true, uniqueness: true
  validates :grupo, inclusion: { in: GRUPOS }
  validates :saldo, numericality: { greater_than_or_equal_to: 0.00 }

  # Returns true when the student is exempt from meal charges (Grupo I).
  #
  # @return [Boolean]
  def isento?
    grupo == "Grupo I"
  end

  # Returns the meal price for the given shift, based on the student's group.
  #
  # @param turno [String] one of "Café da manhã", "Almoço", "Jantar"
  # @return [BigDecimal] price in BRL, or 0.0 when the shift is unknown
  def tarifa_para(turno)
    BigDecimal((TARIFAS.dig(grupo, turno) || 0.0).to_s)
  end

  # Persists the given recharge and adds its value to the student's balance.
  #
  # Runs inside a database transaction: if saving the recharge fails, the
  # balance update is rolled back.
  #
  # @param recarga [Recarga] an unsaved recharge to attach to this student
  # @return [Recarga] the persisted recharge
  # @raise [ActiveRecord::RecordInvalid] if the recharge fails validation
  def adicionar_recarga(recarga)
    transaction do
      recarga.estudante = self
      recarga.save!
      update!(saldo: (saldo + recarga.valor).round(2))
    end
    recarga
  end
end
