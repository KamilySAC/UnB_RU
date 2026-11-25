class AllowNullEmailOnEstudantes < ActiveRecord::Migration[8.1]
  def change
    change_column_null :estudantes, :email, true
  end
end
