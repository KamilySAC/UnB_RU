class CreateMovimentacoesTables < ActiveRecord::Migration[8.1]
  def change
    # tabela de recargas realizadas pelos estudantes
    create_table :recargas, if_not_exists: true do |t|
      t.references :estudante, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false # Valor recarregado
      t.string :forma, default: "PIX", null: false          # PIX ou Cartão
      t.string :status, default: "Aprovada", null: false     # Status do pagamento
      t.date :data, null: false                             # Data da recarga (usada no filtro do mês)
      t.timestamps
    end


    # tabela de refeições realizadas pelos estudantes, débitos de refeições
    create_table :refeicoes, if_not_exists: true do |t|
      t.references :estudante, null: false, foreign_key: true
      t.string :restaurante, default: "RU Darcy Ribeiro", null: false
      t.decimal :valor, precision: 10, scale: 2, null: false # Tarifa paga
      t.date :data, null: false                              # Data da refeição (usada no filtro do mês)
      t.timestamps
    end
  end
end
