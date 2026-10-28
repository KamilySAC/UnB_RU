class Refeicao < ApplicationRecord
  self.table_name = 'refeicoes'

  belongs_to :estudante

  validates :valor,       numericality: { greater_than: 0 }
  validates :restaurante, presence: true
  validates :data,        presence: true
end
