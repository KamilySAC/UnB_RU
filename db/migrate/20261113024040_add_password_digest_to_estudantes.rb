class AddPasswordDigestToEstudantes < ActiveRecord::Migration[8.1]
  def change
    add_column :estudantes, :password_digest, :string
  end
end
