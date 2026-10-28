Dado('que estou autenticado como estudante') do
  @estudante = Estudante.create!(email: 'aluno@teste.com', nome: 'Ana')
  page.driver.post login_path, email: @estudante.email
end

Dado('possuo movimentações registradas na minha conta') do
  @estudante.adicionar_recarga(
    Recarga.new(valor: 50.0, forma: 'PIX', data: Date.new(2026, 10, 5))
  )
  @estudante.refeicoes.create!(
    restaurante: 'RU Central', valor: 8.5, data: Date.new(2026, 10, 10)
  )
end

Dado('que não possuo refeições registradas no período') do
  @estudante.refeicoes.destroy_all
end

Quando('eu acesso a opção {string}') do |opcao|
  case opcao
  when 'Extrato de recargas'    then visit extrato_recargas_path
  when 'Histórico de refeições' then visit extrato_refeicoes_path
  when 'Meus gastos'            then visit painel_path
  else raise "Opção desconhecida: #{opcao}"
  end
end

Então('devo visualizar a lista de recargas realizadas') do
  expect(page).to have_css('#tabela_recargas')
end

Então('cada recarga deve apresentar data, valor e forma de pagamento') do
  expect(page).to have_content('R$ 50.00')
  expect(page).to have_content('PIX')
end

Então('devo visualizar o total recarregado no período') do
  expect(page).to have_css('#total', text: 'Total recarregado')
end

Então('devo visualizar a lista de refeições realizadas') do
  expect(page).to have_css('#tabela_refeicoes')
end

Então('cada refeição deve apresentar data, restaurante e valor debitado') do
  expect(page).to have_content('RU Central')
  expect(page).to have_content('R$ 8.50')
end

Então('devo visualizar o total gasto no período') do
  expect(page).to have_css('#total', text: 'Total gasto')
end

Então('devo visualizar as abas {string} e {string}') do |aba1, aba2|
  expect(page).to have_content(aba1)
  expect(page).to have_content(aba2)
end

Então('ao selecionar {string} devo ver o extrato de recargas') do |aba|
  click_link aba
  expect(page).to have_css('#tabela_recargas')
end

Então('ao selecionar {string} devo ver o histórico de refeições') do |aba|
  click_link aba
  expect(page).to have_css('#tabela_refeicoes')
end

Quando('seleciono o período de {string} a {string}') do |ini, fim|
  fill_in 'inicio', with: ini
  fill_in 'fim',    with: fim
  click_button 'Filtrar'
end

Então('devo visualizar apenas as refeições realizadas nesse período') do
  expect(page).to have_css('#tabela_refeicoes')
end

Então('o total gasto deve considerar apenas o período filtrado') do
  expect(page).to have_css('#total')
end

Quando('seleciono uma recarga da lista') do
  within('#tabela_recargas') { first(:link, 'Detalhes').click }
end

Então('devo visualizar os detalhes da recarga') do
  expect(page).to have_content('Detalhes da recarga')
end

Então('os detalhes devem conter data, valor, forma de pagamento e status') do
  expect(page).to have_content('Data:')
  expect(page).to have_content('Valor:')
  expect(page).to have_content('Forma:')
  expect(page).to have_content('Status:')
end

Então('devo visualizar uma mensagem informando que não há refeições no período') do
  expect(page).to have_content('Nenhuma refeição encontrada no período')
end

Então('o total gasto deve ser R$ {valor_brl}') do |valor|
  expect(page).to have_css('#total', text: "Total gasto: R$ #{format('%.2f', valor)}")
end

Então('devo visualizar apenas as minhas recargas') do
  expect(page).to have_css('#tabela_recargas')
end

Então('não devo visualizar recargas de outros estudantes') do
  expect(page).to have_no_content('999.00')
end
