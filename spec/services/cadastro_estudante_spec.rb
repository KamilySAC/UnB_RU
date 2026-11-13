require "rails_helper"

RSpec.describe CadastroEstudante do
  describe "#call" do
    it "cria a conta com dados válidos"
    it "não cria a conta quando há campo vazio"
    it "não cria a conta quando as senhas são diferentes"
    it "não cria a conta quando a matrícula já existe"
    it "guarda a senha criptografada"
  end
end