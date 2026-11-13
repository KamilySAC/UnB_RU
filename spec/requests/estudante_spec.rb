require "rails_helper"

RSpec.describe "Cadastro de estudante", type: :request do
  describe "GET /cadastro" do
    it "exibe o formulário"
  end

  describe "POST /cadastro" do
    it "cria a conta e inicia a sessão com dados válidos"
    it "reexibe o formulário com erro quando as senhas são diferentes"
    it "reexibe o formulário com erro quando há campo vazio"
    it "reexibe o formulário com erro quando a matrícula já existe"
  end
end