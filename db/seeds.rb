# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# funcionários de demonstração (só em desenvolvimento)
if Rails.env.development?
  Funcionario.find_or_create_by!(matricula_siape: "2948102") do |f|
    f.nome = "Fulano D."
    f.usuario = "fulano.fiscal"
    f.password = "Senha@123"
    f.papel = "fiscal"
  end

  Funcionario.find_or_create_by!(matricula_siape: "1234567") do |f|
    f.nome = "Admin Demo"
    f.usuario = "admin.ru"
    f.password = "Admin@1234"
    f.papel = "administrador"
  end
end