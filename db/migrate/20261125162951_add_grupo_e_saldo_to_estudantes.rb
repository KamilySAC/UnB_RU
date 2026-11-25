class AddGrupoESaldoToEstudantes < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:estudantes, :grupo)
      add_column :estudantes, :grupo, :string, default: "Grupo II", null: false
    end

    unless column_exists?(:estudantes, :curso)
      add_column :estudantes, :curso, :string
    end

    unless column_exists?(:estudantes, :turno)
      add_column :estudantes, :turno, :string
    end

    unless column_exists?(:estudantes, :campus)
      add_column :estudantes, :campus, :string
    end
  end
end
