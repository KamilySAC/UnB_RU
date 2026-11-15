class Restaurante < ApplicationRecord
  has_many :catracas, dependent: :restrict_with_error

  validates :nome, presence: true, uniqueness: true
  validates :capacidade_por_hora, numericality: { greater_than_or_equal_to: 0 }
  validates :total_pisos, numericality: { greater_than: 0 }
end
