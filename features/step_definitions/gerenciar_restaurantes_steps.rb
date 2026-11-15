
Dado('que estou autenticado como administrador') do
  @papel = :administrador
end

Dado('que estou autenticado como funcionário') do
  @papel = :funcionario
end

# Cenário: Cadastrar um restaurante (Caminho Feliz).
Quando('cadastro o restaurante {string}') do |nome|
  visit new_restaurante_path
  preencher_formulario_restaurante(codigo: '01', nome: nome)
  clicar_enviar_formulario
end

Entao('o restaurante {string} deve aparecer na lista de restaurantes') do |nome|
  raise 'O restaurante não apareceu na lista' unless page.has_text?(nome)
end

Entao('deve estar disponível na Aplicação de Controle') do
  raise 'O link para adicionar catraca não apareceu' unless page.has_link?('Adicionar catraca')
end

# Prepara um restaurante usado nos cenários de edição, catraca e nome duplicado.
Dado('existe o restaurante {string}') do |nome|
  @restaurante = Restaurante.create!(
    codigo: '01',
    nome: nome,
    capacidade_por_hora: 100,
    total_pisos: 3
  )
end

# Cenário: Adicionar uma catraca a um restaurante (Caminho Feliz).
Quando('adiciono a catraca {string} ao restaurante {string}') do |nome_catraca, nome_restaurante|
  @restaurante = Restaurante.find_by!(nome: nome_restaurante)
  @catraca_nome = nome_catraca
  visit new_restaurante_catraca_path(@restaurante)
  fill_in 'Código', with: 'CAT-01'
  fill_in 'Nome', with: nome_catraca
  fill_in 'Piso', with: 1
  clicar_enviar_formulario
end

Entao('a catraca {string} deve aparecer nos detalhes do restaurante') do |nome_catraca|
  raise 'A catraca não apareceu na lista' unless page.has_text?(nome_catraca)
end

Entao('deve estar disponível na Aplicação de Controle para esse restaurante') do
  raise 'A catraca não apareceu nos detalhes do restaurante' unless page.has_css?('li', text: @catraca_nome)
end

# Cenário: Editar um restaurante (Caminho Feliz).
Quando('altero o nome do restaurante para {string}') do |novo_nome|
  visit edit_restaurante_path(@restaurante)
  fill_in 'Nome', with: novo_nome
  clicar_enviar_formulario
end

Entao('o restaurante deve aparecer como {string} na lista') do |nome|
  raise 'O nome atualizado não apareceu na lista' unless page.has_text?(nome)
end

# Cenário: Editar uma catraca (Caminho Feliz).
Dado('existe a catraca {string} associada ao restaurante {string}') do |nome_catraca, nome_restaurante|
  @restaurante = Restaurante.create!(
    codigo: '01',
    nome: nome_restaurante,
    capacidade_por_hora: 100,
    total_pisos: 3
  )
  @catraca = @restaurante.catracas.create!(
    codigo: 'CAT-01',
    nome: nome_catraca,
    piso: 1,
    status: :online
  )
end

Quando('altero o estado da catraca para {string}') do |estado|
  visit edit_catraca_path(@catraca)
  select estado, from: 'Status'
  clicar_enviar_formulario
end

Entao('a catraca deve aparecer como {string} nos detalhes do restaurante') do |estado|
  raise 'O estado atualizado da catraca não apareceu' unless page.has_css?('li', text: /#{Regexp.escape(estado)}/)
end

# Cenário: Impedir cadastro de restaurante sem nome (Caminho Triste).
Quando('tento cadastrar um restaurante sem informar o nome') do
  visit new_restaurante_path
  preencher_formulario_restaurante(codigo: '01', nome: '')
  clicar_enviar_formulario
end

Entao('o restaurante não deve ser cadastrado') do
  raise 'O formulário de cadastro não foi exibido novamente' unless page.has_text?('Novo restaurante')
end

Entao('devo ser informado que o nome é obrigatório') do
  raise 'A mensagem de validação do nome não apareceu' unless page.has_css?('[role="alert"]', text: /(Nome|Name).*(blank|obrigat)/i)
end

# Cenário: Impedir cadastro de restaurante com nome já utilizado (Caminho Triste).
Quando('tento cadastrar outro restaurante chamado {string}') do |nome|
  visit new_restaurante_path
  preencher_formulario_restaurante(codigo: '02', nome: nome)
  clicar_enviar_formulario
end

Entao('o novo restaurante não deve ser cadastrado') do
  raise 'O formulário de cadastro não foi exibido novamente' unless page.has_text?('Novo restaurante')
end

Entao('devo ser informado que já existe um restaurante com esse nome') do
  raise 'A mensagem de nome duplicado não apareceu' unless page.has_css?('[role="alert"]', text: /(Nome|Name).*(taken|cadastrado|utilizado)/i)
end

# Cenário: Impedir que funcionário cadastre um restaurante (Caminho Triste).
Quando('tento acessar o cadastro de restaurantes') do
  visit restaurantes_path
end

Entao('não devo poder cadastrar restaurantes') do
  pending('A aplicação ainda não implementa autorização por papel.')
end

# Cenário: Impedir adição de catraca a restaurante inexistente (Caminho Triste).
Dado('não existe o restaurante {string}') do |nome|
  @nome_restaurante_inexistente = nome
  @catracas_antes = Catraca.count
end

Quando('tento adicionar a catraca {string} ao restaurante {string}') do |_nome_catraca, _nome_restaurante|
  visit new_restaurante_catraca_path(restaurante_id: -1)
rescue ActiveRecord::RecordNotFound
  @restaurante_nao_encontrado = true
end

Entao('a catraca não deve ser cadastrada') do
  raise 'O restaurante inexistente não foi rejeitado' unless @restaurante_nao_encontrado
  raise 'Uma catraca foi cadastrada para restaurante inexistente' unless Catraca.count == @catracas_antes
end

def preencher_formulario_restaurante(codigo:, nome:)
  fill_in 'Código', with: codigo
  fill_in 'Nome', with: nome
  fill_in 'Campus', with: 'Darcy Ribeiro'
  fill_in 'Capacidade por hora', with: 100
  fill_in 'Total de pisos', with: 3
end

def clicar_enviar_formulario
  within('form') { find('input[type="submit"]').click }
end
