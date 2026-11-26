# Representa o registro de uma refeição consumida por um estudante
# em um restaurante universitário específico, armazenando valor debitado e data.
class Refeicao < ApplicationRecord
  self.table_name = "refeicoes"

  belongs_to :estudante

  validates :valor, numericality: { greater_than: 0 }
  validates :restaurante, presence: true
  validates :data, presence: true
end
