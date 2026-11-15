# Passo compartilhado por exportar_historico_pdf.feature e extrato_historico.feature
Dado("que estou autenticado como estudante") do
  @estudante = Estudante.create!(
    nome: "Arthur Santos",
    matricula: "242009990",
    grupo: "Grupo II",
    saldo: 25.00,
    password: "senha123"
  )
  page.driver.post login_path, matricula: @estudante.matricula, senha: "senha123"
end