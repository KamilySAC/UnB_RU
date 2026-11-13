class Recarga < ApplicationRecord
  # relação: cada recarga pertence a um estudante específico
  belongs_to :estudante

  # o valor deve ser positivo e a data é obrigatória
  validates :valor, numericality: { greater_than: 0 }
  validates :data, presence: true
end
