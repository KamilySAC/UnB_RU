# bloco 1: dado
#
# Cria o estudante e simula que ele está autenticado
Dado(/^que estou autenticado como estudante$/) do
  @estudante = Estudante.create!(
    nome: "Arthur Santos",
    matricula: "242009990",
    grupo: "Grupo II",
    saldo: 25.00
  )
end


# Cria recargas e refeições registradas no mês atual
Dado(/^possuo movimentações registradas no mês atual$/) do
  hoje = Date.current
  # Recarga de R$ 50,00 no mês atual
  @estudante.recargas.create!(valor: 50.00, forma: "PIX", data: hoje)

  # Refeição consumida de R$ 4,50 no mês atual
  @estudante.refeicoes.create!(valor: 4.50, data: hoje, restaurante: "RU Darcy Ribeiro")
end


# Cria movimentações antigas (mês passado) e movimentações recentes (mês atual)
Dado(/^possuo movimentações registradas no mês atual e em meses anteriores$/) do
  # Movimentações de meses anteriores (devem ser ignoradas pelo PDF)
  @estudante.recargas.create!(valor: 100.00, data: 1.month.ago.to_date)
  @estudante.refeicoes.create!(valor: 30.00, data: 2.months.ago.to_date, restaurante: "RU Darcy Ribeiro")

  # Movimentações do mês atual (devem aparecer no PDF)
  hoje = Date.current
  @estudante.recargas.create!(valor: 40.00, forma: "PIX", data: hoje)
  @estudante.refeicoes.create!(valor: 4.50, data: hoje, restaurante: "RU Darcy Ribeiro")
end



# Garante que o estudante não possua nenhuma movimentação no mês atual
Dado(/^não possuo movimentações registradas no mês atual$/) do
  inicio_mes = Date.current.beginning_of_month
  fim_mes    = Date.current.end_of_month
  @estudante.recargas.where(data: inicio_mes..fim_mes).destroy_all
  @estudante.refeicoes.where(data: inicio_mes..fim_mes).destroy_all
end



# bloco 2: quando
# Simula a solicitação de exportação do histórico em PDF
Quando(/^(?:solicito a exportação do meu|tento exportar o) histórico em PDF$/) do
  @gerador = GeradorHistoricoPdf.new(@estudante)
  @pdf_data = @gerador.gerar
  @mensagem_aviso = "Não há movimentações registradas no mês atual" unless @gerador.possui_movimentacoes?
end


# bloco 3: entao
# Verifica se o arquivo PDF foi gerado com o nome correto
Então(/^o arquivo "([^"]*)" deve ser gerado para download$/) do |nome_arquivo|
  expect(GeradorHistoricoPdf::NOME_ARQUIVO).to eq(nome_arquivo)
  expect(@pdf_data).not_to be_nil

  # Todo arquivo PDF válido do mundo começa com a assinatura binária %PDF
  expect(@pdf_data.start_with?("%PDF")).to be true
end


# Verifica se apenas as movimentações do mês atual entraram no relatório
Então(/^o relatório deve apresentar automaticamente apenas as movimentações do mês atual$/) do
  inicio_mes = Date.current.beginning_of_month
  fim_mes    = Date.current.end_of_month
  expect(@gerador.recargas.all? { |r| r.data >= inicio_mes && r.data <= fim_mes }).to be true
  expect(@gerador.refeicoes.all? { |r| r.data >= inicio_mes && r.data <= fim_mes }).to be true
end


# Verifica se os dados do discente, saldo e totais estão presentes
Então(/^deve exibir os dados do discente, o saldo atual e os totais consumidos e recarregados no mês$/) do
  expect(@gerador.estudante.nome).to eq("Arthur Santos")
  expect(@gerador.estudante.matricula).to eq("242009990")
  expect(@gerador.estudante.saldo).to eq(25.00)
  expect(@gerador.total_recarregado).to eq(50.00)
  expect(@gerador.total_consumido).to eq(4.50)
end


# Verifica que movimentações anteriores ficaram de fora
Então(/^o arquivo PDF gerado não deve conter os registros de meses anteriores$/) do
  inicio_mes = Date.current.beginning_of_month
  # Nenhuma recarga com data anterior ao início do mês deve constar
  expect(@gerador.recargas.any? { |r| r.data < inicio_mes }).to be false
  expect(@gerador.refeicoes.any? { |r| r.data < inicio_mes }).to be false
end


# Verifica se os totais somam exclusivamente o mês atual
Então(/^os totais calculados devem contabilizar exclusivamente o mês atual$/) do
  expect(@gerador.total_recarregado).to eq(40.00)
  expect(@gerador.total_consumido).to eq(4.50)
end


# Verifica que nenhum arquivo foi gerado no caminho triste
Então(/^nenhum arquivo deve ser baixado$/) do
  expect(@pdf_data).to be_nil
end


# Verifica a mensagem de erro informativa
Então(/^devo visualizar a mensagem "([^"]*)"$/) do |mensagem_esperada|
  expect(@mensagem_aviso).to eq(mensagem_esperada)
end
