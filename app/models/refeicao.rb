class Refeicao < ApplicationRecord
  # avisa ao Rails o nome pluralizado em pt-br da tabela
  self.table_name = "refeicoes"

  # relacionamento: cada refeição pertence a um restaurante
  belongs_to :estudante

  # validações: valor deve ser positivo, data e restaurante são obrigatórias
  validates :valor, numericality: { greater_than: 0 }
  validates :data, presence: true
  validates :restaurante, presence: true
end
