# frozen_string_literal: true

# A top-up (recarga) made by a student via PIX or credit card.
#
# Each recarga belongs to a student and must have a positive value,
# a valid payment form, a valid status, and a date.
class Recarga < ApplicationRecord
  # Accepted payment methods.
  FORMAS = [ "PIX", "Cartão de crédito" ].freeze

  # Possible processing statuses.
  STATUS = [ "Aprovada", "Pendente", "Recusada" ].freeze

  belongs_to :estudante

  validates :valor, numericality: { greater_than: 0 }
  validates :forma, inclusion: { in: FORMAS }
  validates :status, inclusion: { in: STATUS }
  validates :data, presence: true
end
