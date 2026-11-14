class CreateAcessos < ActiveRecord::Migration[8.1]
  def change
    create_table :acessos do |t|
      t.references :catraca, null: false, foreign_key: true
      t.string :matricula_discente, null: false
      t.string :turno, null: false
      t.string :modo_validacao, null: false
      t.decimal :tarifa, precision: 8, scale: 2, null: false
      t.integer :status_acesso, null: false
      t.string :status_catraca, null: false
      t.string :motivo_negativa
      t.datetime :ocorrido_em, null: false

      t.timestamps
    end

    add_index :acessos, [ :catraca_id, :ocorrido_em ]
    add_index :acessos, [ :catraca_id, :status_acesso ]
    add_index :acessos, [ :catraca_id, :turno ]
  end
end
