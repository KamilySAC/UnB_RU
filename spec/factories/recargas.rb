FactoryBot.define do
  factory :recarga do
    association :estudante
    valor  { 10.0 }
    forma  { "PIX" }
    status { "Aprovada" }
    data   { Date.today }
  end
end
