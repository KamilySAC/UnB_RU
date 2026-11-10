class Catraca < ApplicationRecord
  belongs_to :restaurante
  has_many :acessos, dependent: :restrict_with_error

  enum :status, { offline: 0, online: 1}

  validates :codigo, presence: true, uniqueness: { scope: :restaurante_id }
  validates :nome, presence: true
  validates :piso, numericality: { only_integer: true, greater_than: 0 }
  validate  :piso_existe_no_restaurante

  private

end