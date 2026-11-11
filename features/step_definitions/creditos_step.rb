Dado('que estou logado como estudante') do
  @estudante = Estudante.create!(email: 'aluno@teste.com', nome: 'Ana', saldo: 0)
  page.driver.post login_path, email: @estudante.email
end

Dado('meu saldo atual é de R$ {valor_brl}') do |valor|
  @estudante.update!(saldo: valor)
end

Quando('eu escolho a opção de pagamento via PIX') do
  visit recarga_path
end

Quando('eu gero um QR Code de recarga no valor de R$ {valor_brl}') do |valor|
  @valor = valor
  fill_in 'valor_pix', with: valor
  click_button 'Gerar QR Code PIX'
end

Quando('eu realizo o pagamento do PIX') do
  click_button 'Confirmar pagamento PIX'
end

Então('meu saldo deve ser atualizado para +R$ {valor_brl}') do |valor|
  expect(page).to have_content("Saldo: R$ #{format('%.2f', valor)}")
end

Então('uma mensagem de sucesso deve ser exibida') do
  expect(page).to have_content('Recarga realizada com sucesso')
end

Quando('eu escolho a opção de pagamento via cartão de crédito') do
  visit recarga_path
end

Quando('eu insiro os dados de um cartão de crédito válido') do
  fill_in 'numero', with: '4111111111111111'
  fill_in 'cvv',    with: '123'
end

Quando('eu insiro dados inválidos do cartão de crédito') do
  fill_in 'numero', with: '12'
  fill_in 'cvv',    with: '1'
end

Quando('eu confirmo a recarga no valor de R$ {valor_brl}') do |valor|
  fill_in 'valor_cartao', with: valor
  click_button 'Confirmar recarga'
end

Quando('eu tento confirmar a recarga') do
  fill_in 'valor_cartao', with: '100,00'
  click_button 'Confirmar recarga'
end

Então('uma mensagem de erro deve ser exibida') do
  expect(page).to have_content('Dados do cartão inválidos')
end

Então('meu saldo não deve ser alterado') do
  expect(page).to have_content('Saldo: R$ 0.00')
end
