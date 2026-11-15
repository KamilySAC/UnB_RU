class CreateFuncionarios < ActiveRecord::Migration[8.1]
  def change
    create_table :funcionarios do |t|
      t.string :nome,            null: false
      t.string :matricula_siape, null: false
      t.string :usuario
      t.string :password_digest, null: false
      t.string :papel,           null: false, default: "fiscal"

      t.timestamps
    end

    add_index :funcionarios, :matricula_siape, unique: true
    add_index :funcionarios, :usuario, unique: true
  end
end