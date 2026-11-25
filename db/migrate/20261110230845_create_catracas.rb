class CreateCatracas < ActiveRecord::Migration[8.1]
  def change
    create_table :catracas do |t|
      t.references :restaurante, null: false, foreign_key: true
      t.string  :nome,     null: false
      t.integer :piso,     null: false, default: 1
      t.integer :status,   null: false, default: 1

      t.timestamps
    end

    add_index :catracas, [ :restaurante_id, :nome ], unique: true
    add_index :catracas, [ :restaurante_id, :piso ]
  end
end
