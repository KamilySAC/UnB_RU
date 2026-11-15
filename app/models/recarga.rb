class Recarga < ApplicationRecord
  FORMAS = [ "PIX", "Cartão de crédito" ].freeze
  STATUS = [ "Aprovada", "Pendente", "Recusada" ].freeze

  # relação: cada recarga pertence a um estudante específico
  belongs_to :estudante

  # validações
  validates :valor, numericality: { greater_than: 0 }
  validates :forma, inclusion: { in: FORMAS }
  validates :status, inclusion: { in: STATUS }
  validates :data, presence: true
end