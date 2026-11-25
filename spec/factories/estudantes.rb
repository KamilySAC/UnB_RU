FactoryBot.define do
  factory :estudante do
    sequence(:nome)      { |n| "Estudante #{n}" }
    sequence(:matricula) { |n| format("24%09d", n) }
    grupo                { "Grupo II" }
    saldo                { 0.0 }
    password             { "senha123" }
  end
end
