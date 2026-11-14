class CreateRestaurantes < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurantes do |t|
      t.string  :codigo,              null: false
      t.string  :nome,                null: false
      t.string  :campus
      t.integer :capacidade_por_hora, null: false, default: 0
      t.integer :total_pisos,         null: false, default: 1

      t.timestamps
    end

    add_index :restaurantes, :codigo, unique: true
  end
end
