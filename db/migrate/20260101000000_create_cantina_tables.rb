class CreateCantinaTables < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:estudantes)
      create_table :estudantes do |t|
        t.string  :email, null: false
        t.string  :nome,  null: false
        t.decimal :saldo, precision: 10, scale: 2, default: 0.0, null: false
        t.timestamps
      end
    end
    if column_exists?(:estudantes, :email)
      add_index :estudantes, :email, unique: true, if_not_exists: true
    end

    unless table_exists?(:recargas)
      create_table :recargas do |t|
        t.references :estudante, null: false, foreign_key: true
        t.decimal :valor,  precision: 10, scale: 2, null: false
        t.string  :forma,  null: false
        t.string  :status, null: false, default: 'Aprovada'
        t.date    :data,   null: false
        t.timestamps
      end
    end

    unless table_exists?(:refeicoes)
      create_table :refeicoes do |t|
        t.references :estudante, null: false, foreign_key: true
        t.string  :restaurante, null: false
        t.decimal :valor, precision: 10, scale: 2, null: false
        t.date    :data,  null: false
        t.timestamps
      end
    end
  end
end
