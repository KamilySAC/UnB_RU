class Estudante < ApplicationRecord
  has_many :recargas,  dependent: :destroy
  has_many :refeicoes, class_name: "Refeicao", dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :nome,  presence: true
  validates :saldo, numericality: { greater_than_or_equal_to: 0 }

  def adicionar_recarga(recarga)
    transaction do
      recarga.estudante = self
      recarga.save!
      update!(saldo: (saldo + recarga.valor).round(2))
    end
    recarga
  end
end
