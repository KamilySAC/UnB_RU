# Passos da feature "Cadastrar estudante" (features/cadastro_usuario.feature).
# Os cenários passam pela tela de verdade (formulário /cadastro) e conferem o banco.

module CadastroUsuarioHelpers
  SENHA_VALIDA = "senha123".freeze

  # dados que serão digitados no formulário; cada passo "Dado" vai preenchendo
  def dados_cadastro
    @dados_cadastro ||= { matricula: "", nome: "", senha: "", confirmacao_senha: "" }
  end
end
World(CadastroUsuarioHelpers)


# bloco 1: dado

Dado(/^que informei corretamente minha matrícula$/) do
  dados_cadastro[:matricula] = "250000001"
end

Dado(/^inseri meu nome completo$/) do
  dados_cadastro[:nome] = "Ana Sarah Nagata"
end

Dado(/^inseri senhas válidas iguais$/) do
  dados_cadastro[:senha] = CadastroUsuarioHelpers::SENHA_VALIDA
  dados_cadastro[:confirmacao_senha] = CadastroUsuarioHelpers::SENHA_VALIDA
end

Dado(/^ainda não possuo cadastro$/) do
  expect(Estudante.exists?(matricula: dados_cadastro[:matricula])).to be false
end

Dado(/^que informei duas senhas diferentes$/) do
  dados_cadastro[:senha] = CadastroUsuarioHelpers::SENHA_VALIDA
  dados_cadastro[:confirmacao_senha] = "outraSenha456"
end

Dado(/^preenchi corretamente o nome e a matrícula$/) do
  dados_cadastro[:matricula] = "250000001"
  dados_cadastro[:nome] = "Ana Sarah Nagata"
end

Dado(/^que deixei pelo menos um campo obrigatório sem preencher$/) do
  # tudo preenchido, exceto o nome completo
  dados_cadastro[:matricula] = "250000001"
  dados_cadastro[:nome] = ""
  dados_cadastro[:senha] = CadastroUsuarioHelpers::SENHA_VALIDA
  dados_cadastro[:confirmacao_senha] = CadastroUsuarioHelpers::SENHA_VALIDA
end

Dado(/^que informei uma matrícula que já foi cadastrada$/) do
  @estudante_existente = Estudante.create!(nome: "Aluno Existente", matricula: "250000002")
  dados_cadastro[:matricula] = "250000002"
  dados_cadastro[:nome] = "Ana Sarah Nagata"
  dados_cadastro[:senha] = CadastroUsuarioHelpers::SENHA_VALIDA
  dados_cadastro[:confirmacao_senha] = CadastroUsuarioHelpers::SENHA_VALIDA
end


# bloco 2: quando

Quando(/^tento realizar meu cadastro$/) do
  @total_estudantes_antes = Estudante.count

  visit cadastro_path
  fill_in "estudante_matricula", with: dados_cadastro[:matricula]
  fill_in "estudante_nome", with: dados_cadastro[:nome]
  fill_in "estudante_senha", with: dados_cadastro[:senha]
  fill_in "estudante_confirmacao_senha", with: dados_cadastro[:confirmacao_senha]
  click_button "Cadastrar"
end


# bloco 3: então

Então(/^minha conta deve ser criada com sucesso$/) do
  expect(Estudante.count).to eq(@total_estudantes_antes + 1)

  estudante = Estudante.find_by(matricula: dados_cadastro[:matricula])
  expect(estudante).not_to be_nil
  expect(estudante.nome).to eq(dados_cadastro[:nome])
  # a senha é guardada criptografada, mas permite autenticar
  expect(estudante.authenticate(dados_cadastro[:senha])).to be_truthy
end

Então(/^uma mensagem informando a confirmação deve ser exibida$/) do
  expect(page).to have_content(CadastroEstudante::MSG_SUCESSO)
end

Então(/^minha conta não deve ser criada$/) do
  expect(Estudante.count).to eq(@total_estudantes_antes)
  expect(Estudante.where(nome: dados_cadastro[:nome], matricula: dados_cadastro[:matricula]).where.not(password_digest: nil))
    .to be_empty
end

Então(/^uma mensagem informando que as senhas não são iguais deve ser exibida$/) do
  expect(page).to have_content("As senhas não são iguais")
end

Então(/^uma mensagem informando que todos os campos devem ser preenchidos deve ser exibida$/) do
  expect(page).to have_content("Todos os campos devem ser preenchidos")
end

Então(/^uma mensagem informando que a matrícula já foi cadastrada deve ser exibida$/) do
  expect(page).to have_content("Matrícula já cadastrada")
  # a conta que já existia continua intacta
  expect(Estudante.where(matricula: "250000002").count).to eq(1)
  expect(@estudante_existente.reload.nome).to eq("Aluno Existente")
end