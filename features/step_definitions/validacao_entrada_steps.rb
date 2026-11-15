def parse_moeda(valor_str)
  BigDecimal(valor_str.to_s.tr(',', '.').tr(",", "."))
end

# Dado: preparação dos estados inicial dos cenários


# cria o estudante do grupo 1 com isenção integral
Dado(/^que o estudante pertence ao "([^"]*)" com benefício de isenção integral$/) do |grupo|
  @estudante = Estudante.create!(
    nome: "Estudante Isento",
    matricula: "111111111",
    grupo: grupo,
    saldo: 0.00
  )
  @turno_atual = "Almoço"
end


# define ou atualiza o saldo do aluno no cenário
Dado(/^(?:que )?o (?:estudante|aluno|servidor|terceirizado) possui saldo de R\$ ([0-9]+(?:,[0-9]{2})?)$/) do |saldo_str|
  saldo = parse_moeda(saldo_str)

  if @estudante
    # se o estudante foi criado no passo anterior, apenas atualiza os dados dele
    @estudante.update!(saldo: saldo)

  else
    @estudante = Estudante.create!(
      nome: "Arthur Santos",
      matricula: "242009990",
      grupo: @grupo_atual || "Grupo II",
      saldo: saldo
    )
  end
end

# utilizado no esquema do cenário para configurar o turno e a tarífa oficial daquele grupo
Dado(/^que o turno atual é "([^"]*)" e a tarifa para o "([^"]*)" é de R\$ ([0-9]+(?:,[0-9]{2})?)$/) do |turno, grupo, tarifa_str|
  @turno_atual = turno
  @grupo_atual = grupo
  @tarifa_esperada = parse_moeda(tarifa_str)
end

# cria um discente de um grupo específico com um saldo determinado
Dado(/^que o aluno do "([^"]*)" possui saldo de R\$ ([0-9]+(?:,[0-9]{2})?)$/) do |grupo, saldo_str|
  @grupo_atual = grupo
  @estudante = Estudante.create!(
    nome: "Aluno " + grupo,
    matricula: "242009990",
    grupo: grupo,
    saldo: parse_moeda(saldo_str)
  )
  @turno_atual = "Almoço"
end

# garante que uma determinada matrícula não exista no banco  - para teste de matricula inválida
Dado(/^que a identificação "([^"]*)" não existe na base de dados$/) do |identificacao|
  Estudante.find_by(matricula: identificacao)&.destroy
  @turno_atual = "Almoço"
end


# prepara a catraca já no estado "liberada" aguardando o giro
Dado(/^a catraca foi liberada com timeout de (\d+) segundos$/) do |_segundos|
  @acesso = AcessoCatraca.ler_identificacao(
    identificacao: @estudante.matricula,
    turno: @turno_atual
  )
  expect(@acesso.status_catraca).to eq("liberada")
end

# prepara o cenário de recusa de entrada dupla, simulando que o aluno passou no mesmo turno.
Dado(/^o aluno já possui uma passagem registrada no turno "([^"]*)" de hoje$/) do |turno|
  @turno_atual = turno
  saldo_inicial = @estudante.saldo
  primeiro_acesso = AcessoCatraca.ler_identificacao(
    identificacao: @estudante.matricula,
    turno: turno
  )
  primeiro_acesso.registrar_giro!
  @estudante.reload
  @estudante.update!(saldo: saldo_inicial)
end



# When: Açoes do usuário e eventos disparados

# simula a leitura do qrcode do aluno no leitor da catraca
Quando(/^a identificação(?: válida)? do (?:estudante|aluno) é lida na catraca$/) do
  @acesso = AcessoCatraca.ler_identificacao(
    identificacao: @estudante.matricula,
    turno: @turno_atual,
    tarifa_customizada: @tarifa_esperada
  )
end


# simula o escaneamento do qr code com identificação não cadastrada/oficial
Quando(/^a identificação "([^"]*)" é lida na catraca$/) do |identificacao|
  @acesso = AcessoCatraca.ler_identificacao(
    identificacao: identificacao,
    turno: @turno_atual
  )
end


# simula o aluno girando o braço mecânico da catraca após a leitura do qrcode
Quando(/^o (?:estudante|aluno) gira a catraca$/) do
  @acesso.registrar_giro!
end


# simula o tempo esgotando após a leitura válida do qrcode sem que haja o giro fisica da catraca
Quando(/^passam-se (\d+) segundos sem que o sensor de giro seja acionado$/) do |segundos|
  @acesso.verificar_timeout!(segundos.to_i)
end


# simula o discente tentando escanear o QR code uma segunda vez no mesmo turno
Quando(/^o aluno tenta validar a entrada novamente no mesmo turno "([^"]*)"$/) do |turno|
  @acesso = AcessoCatraca.ler_identificacao(
    identificacao: @estudante.matricula,
    turno: turno
  )
end


# Então: verificação dos resultados esperados

# Verifica se a catraca destravou
Então(/^a catraca deve ser liberada(?: sem exigir saldo)?$/) do
  expect(@acesso.status_catraca).to eq("liberada")
end


# Verifica se a catraca permaneceu bloqueada
Então(/^a catraca deve permanecer bloqueada$/) do
  expect(@acesso.status_catraca).to eq("bloqueada")
  expect(@acesso.status_acesso).to eq("negado")
end


# Verifica se a catraca voltou a travar após o timeout
Então(/^a catraca volta a ser bloqueada$/) do
  expect(@acesso.reload.status_catraca).to eq("bloqueada")
end


# Verifica a mensagem exibida no visor digital da catraca
Então(/^o visor da catraca deve exibir "([^"]*)"$/) do |mensagem_esperada|
  expect(@acesso.mensagem_visor).to eq(mensagem_esperada)
end


# Verifica se o saldo do discente continuou o mesmo
Então(/^o saldo do (?:estudante|aluno) deve (?:permanecer|se manter em) R\$ ([0-9]+(?:,[0-9]{2})?)$/) do |saldo_esperado_str|
  expect(@estudante.reload.saldo).to eq(parse_moeda(saldo_esperado_str))
end


# Verifica se o saldo foi debitado após o giro
Então(/^o saldo do aluno deve ser debitado para R\$ ([0-9]+(?:,[0-9]{2})?)$/) do |saldo_esperado_str|
  expect(@estudante.reload.saldo).to eq(parse_moeda(saldo_esperado_str))
end


# Verifica que nenhum débito ocorreu no cancelamento por timeout
Então(/^nenhum débito deve ser efetuado mantendo o saldo em R\$ ([0-9]+(?:,[0-9]{2})?)$/) do |saldo_esperado_str|
  expect(@estudante.reload.saldo).to eq(parse_moeda(saldo_esperado_str))
end


# Verifica se o acesso foi registrado como isento (Grupo I)
Então(/^o acesso deve ser registrado como isento no turno atual$/) do
  expect(@acesso.reload.status_acesso).to eq("isento")
  expect(@acesso.isento).to be true
end


# Verifica se o acesso pagante foi registrado com sucesso
Então(/^o acesso deve ser registrado no turno atual$/) do
  expect(@acesso.reload.status_acesso).to eq("registrado")
end


# Verifica se o acesso foi cancelado por timeout
Então(/^o acesso deve ser cancelado$/) do
  expect(@acesso.reload.status_acesso).to eq("cancelado")
end
