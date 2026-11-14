class Acesso < ApplicationRecord
  belongs_to :catraca

  enum :status_acesso, { liberado: 0, bloqueado: 1, cancelado: 2 }
  enum :status_catraca, { offline: "offline", online: "online" }

  validates :matricula_discente, :turno, :modo_validacao, :status_acesso,
            :status_catraca, :ocorrido_em, presence: true
  validates :tarifa, numericality: { greater_than_or_equal_to: 0 }
  validates :motivo_negativa, presence: true, if: :bloqueado?
end
