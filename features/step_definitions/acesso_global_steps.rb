# Passos da feature "Histórico global de acessos do campus" (features/acesso_global.feature).
# O passo "que estou autenticado como administrador" já existe em gerenciar_restaurantes_steps.rb
# (só marca @papel). Aqui o login de verdade acontece na primeira vez que a tela global é aberta.

module AcessoGlobalHelpers
  def global_real(valor)
    ActionController::Base.helpers.number_to_currency(valor, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def global_entrar_como_administrador
    return if @global_admin_logado

    Funcionario.find_or_create_by!(matricula_siape: "1234567") do |f|
      f.nome = "Admin Demo"
      f.password = "Admin@1234"
      f.papel = "administrador"
    end
    autenticar_pela_interface("1234567", "Admin@1234")
    expect(page).to have_button("Sair")
    @global_admin_logado = true
  end

  def global_abrir_historico
    global_entrar_como_administrador
    visit rotas.historico_global_path
    expect(page).to have_css("h1", text: "Histórico Global de Acessos")
  end

  def global_filtrar(restaurante: nil, catraca: nil, agrupar: nil)
    select restaurante, from: "Restaurante" if restaurante
    select catraca, from: "Catraca" if catraca
    select agrupar, from: "Agrupar por" if agrupar
    click_button "Filtrar"
  end

  def global_criar_acesso(catraca, **atributos)
    @global_contador = (@global_contador || 0) + 1
    acesso = catraca.acessos.create!({
                                       matricula_discente: format("MAT-G%03d", @global_contador),
                                       turno: "Almoço",
                                       modo_validacao: "Cartão",
                                       tarifa: 2.0 + (@global_contador * 0.5),
                                       status_acesso: :liberado,
                                       status_catraca: :online,
                                       ocorrido_em: Time.current
                                     }.merge(atributos))
    (@global_acessos ||= []) << acesso
    acesso
  end

  def global_catraca(nome)
    Catraca.find_by!(nome: nome)
  end

  def global_acessos_de(restaurante: nil, catraca: nil)
    relacao = Acesso.joins(:catraca)
    relacao = relacao.where(catracas: { restaurante_id: Restaurante.find_by!(nome: restaurante).id }) if restaurante
    relacao = relacao.where(catraca_id: global_catraca(catraca).id) if catraca
    relacao.to_a
  end

  def global_ver_somente(esperados)
    esperados.each { |a| expect(page).to have_content(a.matricula_discente) }
    (Acesso.all.to_a - esperados).each { |a| expect(page).to have_no_content(a.matricula_discente) }
  end
end
World(AcessoGlobalHelpers)

# ---------- Contexto ----------

Dado("existem os restaurantes {string} e {string} com catracas cadastradas") do |nome_1, nome_2|
  r1 = Restaurante.create!(codigo: "G1", nome: nome_1, capacidade_por_hora: 100, total_pisos: 2)
  r2 = Restaurante.create!(codigo: "G2", nome: nome_2, capacidade_por_hora: 100, total_pisos: 2)
  r1.catracas.create!(codigo: "CAT-01", nome: "Catraca 01", piso: 1, status: :online)
  r1.catracas.create!(codigo: "CAT-04", nome: "Catraca 04", piso: 1, status: :online)
  r2.catracas.create!(codigo: "CAT-02", nome: "Catraca 02", piso: 1, status: :online)
  r2.catracas.create!(codigo: "CAT-05", nome: "Catraca 05", piso: 1, status: :online)
end

# a Catraca 05 fica sem acessos de propósito (cenário do filtro vazio)
Dado("existem acessos registrados nas catracas desses restaurantes") do
  [ "Catraca 01", "Catraca 04", "Catraca 02" ].each { |nome| global_criar_acesso(global_catraca(nome)) }
end

# ---------- Dado ----------

Dado("que houve um acesso bloqueado por {string}") do |motivo|
  @global_bloqueados ||= {}
  @global_bloqueados[motivo] = global_criar_acesso(
    global_catraca("Catraca 01"),
    status_acesso: :bloqueado, motivo_negativa: motivo, tarifa: 0
  )
end

Dado("houve um acesso bloqueado por {string}") do |motivo|
  step %(que houve um acesso bloqueado por "#{motivo}")
end

Dado("que estou no histórico global de acessos") do
  global_abrir_historico
end

Dado("a {string} não possui acessos registrados") do |nome|
  expect(global_catraca(nome).acessos.count).to eq(0)
end

Dado("a {string} pertence ao {string}") do |catraca, restaurante|
  expect(global_catraca(catraca).restaurante.nome).to eq(restaurante)
end

Dado("que estou autenticado como fiscal no aplicativo") do
  @papel = :fiscal
  Funcionario.create!(nome: "Fiscal Teste", matricula_siape: "2948102", password: "Senha@123", papel: "fiscal")
  autenticar_pela_interface("2948102", "Senha@123")
  expect(page).to have_button("Sair")
end

# ---------- Quando ----------

Quando("acesso o histórico global de acessos") do
  global_abrir_historico
end

Quando("tento acessar o histórico global de acessos") do
  visit rotas.historico_global_path
end

Quando("filtro por {string}") do |restaurante|
  global_filtrar(restaurante: restaurante)
end

Quando("filtro pela catraca {string}") do |catraca|
  global_filtrar(catraca: catraca)
end

Quando("agrupo os dados por restaurante") do
  global_filtrar(agrupar: "Restaurante")
end

Quando("agrupo os dados por catraca") do
  global_filtrar(agrupar: "Catraca")
end

# ---------- Então ----------

Então("devo ver os acessos de todos os restaurantes e de todas as catracas do campus") do
  global_ver_somente(Acesso.all.to_a)
end

Então("cada acesso deve exibir horário, matrícula do estudante, tarifa e status da catraca") do
  [ "Horário", "Matrícula", "Tarifa", "Status da catraca" ].each do |cabecalho|
    expect(page).to have_css("th", text: cabecalho)
  end
end

Então("devo ver o total de acessos e a arrecadação bruta do campus") do
  expect(page).to have_css("#total-acessos", text: Acesso.count.to_s)
  expect(page).to have_css("#arrecadacao-bruta", text: global_real(Acesso.liberado.sum(:tarifa)))
end

Então("o total consolidado deve ser a soma dos valores de todos os restaurantes") do
  soma = Restaurante.all.sum do |r|
    Acesso.joins(:catraca).where(catracas: { restaurante_id: r.id }).liberado.sum(:tarifa)
  end
  expect(page).to have_css("#arrecadacao-bruta", text: global_real(soma))
end

Então("esses acessos devem aparecer com tarifa {string}") do |tarifa|
  @global_bloqueados.each_value do |acesso|
    linha = find("tr", text: acesso.matricula_discente)
    expect(linha).to have_content(tarifa)
  end
end

Então("o motivo do bloqueio deve estar visível em cada um") do
  @global_bloqueados.each do |motivo, acesso|
    expect(find("tr", text: acesso.matricula_discente)).to have_content(motivo)
  end
end

Então("devo ver apenas os acessos do {string}") do |restaurante|
  global_ver_somente(global_acessos_de(restaurante: restaurante))
end

Então("devo ver apenas os acessos da {string} do {string}") do |catraca, restaurante|
  global_ver_somente(global_acessos_de(restaurante: restaurante, catraca: catraca))
end

Então("devo ver uma linha para cada restaurante") do
  linhas = all("#agrupado-restaurante tbody tr")
  expect(linhas.size).to eq(Restaurante.count)
  Restaurante.pluck(:nome).each { |nome| expect(page).to have_css("#agrupado-restaurante tbody td", text: nome) }
end

Então("cada linha deve exibir acessos, pontualidade e arrecadação bruta") do
  [ "Acessos", "Pontualidade", "Arrecadação bruta" ].each do |cabecalho|
    expect(page).to have_css("#agrupado-restaurante th", text: cabecalho)
  end
end

Então("devo ver o total consolidado de todos os restaurantes") do
  rodape = find("#agrupado-restaurante tfoot")
  expect(rodape).to have_content("Total consolidado")
  expect(rodape).to have_content(Acesso.count.to_s)
  expect(rodape).to have_content(global_real(Acesso.liberado.sum(:tarifa)))
end

Então("devo ver uma linha para cada catraca") do
  expect(all("#agrupado-catraca tbody tr").size).to eq(Catraca.count)
end

Então(/^cada linha deve exibir passagens\s+e total debitado$/) do
  [ "Passagens", "Total debitado" ].each do |cabecalho|
    expect(page).to have_css("#agrupado-catraca th", text: cabecalho)
  end
end

Então("nenhum acesso deve ser exibido") do
  expect(page).to have_no_css("#acessos-globais")
  Acesso.all.each { |a| expect(page).to have_no_content(a.matricula_discente) }
end

Então("devo ser informado que não há acessos para os filtros selecionados") do
  expect(page).to have_content("Não há acessos para os filtros selecionados.")
end

Então("a {string} não deve estar disponível como opção de filtro") do |catraca|
  opcoes = find_field("Catraca").all("option").map(&:text)
  expect(opcoes.none? { |texto| texto.include?(catraca) }).to be(true)
end

Então("não devo poder visualizar acessos de outras catracas") do
  expect(page).to have_no_css("h1", text: "Histórico Global de Acessos")
  Acesso.all.each { |a| expect(page).to have_no_content(a.matricula_discente) }
end

Então("devo ver apenas o histórico local da minha catraca") do
  expect(page).to have_css("h1", text: "Histórico Local")
  expect(page).to have_content("Você não tem permissão para acessar esta tela.")
end