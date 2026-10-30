class Recarga < ApplicationRecord
  FORMAS = [ "PIX", "Cartão de crédito" ].freeze
  STATUS = [ "Aprovada", "Pendente", "Recusada" ].freeze

  belongs_to :estudante

  validates :valor,  numericality: { greater_than: 0 }
  validates :forma,  inclusion: { in: FORMAS }
  validates :status, inclusion: { in: STATUS }
  validates :data,   presence: true
end
