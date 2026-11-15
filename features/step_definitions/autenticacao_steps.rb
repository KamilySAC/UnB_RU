# Passos da feature "Autenticação do fiscal" (features/autenticar_funcionario.feature).
# Os cenários passam pela tela de verdade (/funcionario/login).

module AutenticacaoHelpers
  CAMPO_IDENTIFICADOR = "Matrícula SIAPE ou usuário".freeze
  CAMPO_SENHA = "Senha".freeze
  BOTAO_ENTRAR = "Entrar no Sistema".freeze

  def rotas
    Rails.application.routes.url_helpers
  end

  def preencher_login(identificador, senha)
    fill_in CAMPO_IDENTIFICADOR, with: identificador
    fill_in CAMPO_SENHA, with: senha
  end

  def autenticar_pela_interface(identificador, senha)
    visit rotas.login_funcionario_path
    preencher_login(identificador, senha)
    click_button BOTAO_ENTRAR
  end
end
World(AutenticacaoHelpers)

# ---------- Contexto ----------

Dado("que existe o fiscal {string} com matrícula SIAPE {string} e senha {string}") do |nome, siape, senha|
  @fiscal = Funcionario.create!(nome: nome, matricula_siape: siape, password: senha, papel: "fiscal")
  @fiscal_senha = senha
end

Dado("que o fiscal {string} também possui o usuário {string}") do |nome, usuario|
  expect(@fiscal.nome).to eq(nome)
  @fiscal.update!(usuario: usuario)
end

# ---------- Dado ----------

Dado("que estou na tela {string}") do |tela|
  visit rotas.login_funcionario_path if tela == "Autenticação do Operador"
  expect(page).to have_css("h1", text: tela)
end

Dado("que me autentiquei como {string} com a matrícula SIAPE {string}") do |nome, siape|
  autenticar_pela_interface(siape, @fiscal_senha)
  expect(page).to have_content(nome)
end

Dado("informei a senha {string}") do |senha|
  fill_in AutenticacaoHelpers::CAMPO_SENHA, with: senha
end

Dado("que estou autenticado como fiscal") do
  autenticar_pela_interface(@fiscal.matricula_siape, @fiscal_senha)
  expect(page).to have_button("Sair")
end

# ---------- Quando ----------

Quando("informo a matrícula SIAPE {string} e a senha {string}") do |siape, senha|
  preencher_login(siape, senha)
end

# aceita espaços a mais antes do valor
Quando(/^informo o identificador\s+"([^"]*)" e a senha "([^"]*)"$/) do |identificador, senha|
  preencher_login(identificador, senha)
end

Quando("deixo o campo de matrícula ou usuário vazio e informo a senha {string}") do |senha|
  preencher_login("", senha)
end

Quando("informo a matrícula SIAPE {string} e deixo a senha vazia") do |siape|
  preencher_login(siape, "")
end

Quando("clico em {string}") do |texto|
  click_button texto
end

Quando("acesso a tela {string}") do |tela|
  visit rotas.configuracao_ponto_path if tela == "Configuração de Ponto de Acesso"
  expect(page).to have_css("h1", text: tela)
end

Quando("clico no ícone de visualizar senha") do
  expect(page).to have_css("[data-controller='senha'][data-senha-pronto='true']")
  find_by_id("alternar-senha").click
end

Quando("clico novamente no ícone de visualizar senha") do
  find_by_id("alternar-senha").click
end

Quando("faço logout") do
  click_button "Sair"
end

# ---------- Então ----------

Então("devo ser autenticado") do
  expect(page).to have_button("Sair") # o botão só aparece com a sessão aberta
end

Então("não devo ser autenticado") do
  expect(page).to have_no_button("Sair")
  expect(page).to have_css("h1", text: "Autenticação do Operador")
end

Então("devo ser direcionado para a tela {string}") do |tela|
  expect(page).to have_css("h1", text: tela)
end

Então("devo ser informado que as credenciais são inválidas") do
  expect(page).to have_content("Credenciais inválidas")
end

Então("devo ser informado que a matrícula ou usuário é obrigatório") do
  expect(page).to have_content("matrícula ou usuário é obrigatório")
end

Então("devo ser informado que a senha é obrigatória") do
  expect(page).to have_content("senha é obrigatória")
end

Então("devo ver {string} e a matrícula {string} identificados como funcionário autenticado") do |nome, siape|
  expect(page).to have_content("Funcionário autenticado")
  expect(page).to have_css("#funcionario-nome", text: nome)
  expect(page).to have_content(siape)
end

Então("devo poder acessar {string}, {string} e {string}") do |tela_a, tela_b, tela_c|
  [ tela_a, tela_b, tela_c ].each do |tela|
    click_link tela
    expect(page).to have_css("h1", text: tela)
  end
end

Então("a senha deve ser exibida em texto") do
  expect(page).to have_field("Senha", type: "text") # o have_field espera até aparecer
end

Então("a senha deve voltar a ficar oculta") do
  expect(page).to have_field("Senha", type: "password")
end

Então("minha sessão deve ser encerrada") do
  visit rotas.configuracao_ponto_path # sem sessão, redireciona para o login
  expect(page).to have_no_button("Sair")
  expect(page).to have_css("h1", text: "Autenticação do Operador")
end