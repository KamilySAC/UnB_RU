#  confere se o histórico mostra os acessos e os dados de cada catraca.
Dado("que existem acessos registrados na {string}") do |nome_catraca|
  @catraca = criar_catraca(nome_catraca)
  @acesso = criar_acesso(@catraca)
end

Quando("acesso a opção {string}") do |opcao|
  raise "Opção de histórico desconhecida: #{opcao}" unless opcao == "Histórico Local"

  visit catraca_acessos_path(@catraca)
end

Então("devo visualizar os acessos registrados nessa catraca") do
  exigir_texto(@acesso.matricula_discente)
end

Então("cada registro deve apresentar horário, matricula do discente, modo de validação, tarifa e status da catraca.") do
  ["Horário", "Matrícula", "Modo de validação", "Tarifa", "Status da catraca"].each do |cabecalho|
    raise "Não apareceu a coluna #{cabecalho}" unless page.has_css?("th", text: cabecalho)
  end
end

# garante que uma catraca não mostra os acessos da outra.
Dado("que existem acessos registrados nas catracas {string} e {string}") do |nome_1, nome_2|
  @catraca_1 = criar_catraca(nome_1)
  @catraca_2 = criar_catraca(nome_2)
  @acesso_1 = criar_acesso(@catraca_1)
  @acesso_2 = criar_acesso(@catraca_2)
end

Quando("acesso o histórico da {string}") do |nome_catraca|
  @catraca = catraca_por_nome(nome_catraca)
  visit catraca_acessos_path(@catraca)
end

Então("não devo visualizar registros da {string}") do |nome_catraca|
  acesso = acessos_por_catraca(nome_catraca).last
  raise "O acesso de #{nome_catraca} apareceu no histórico" if page.has_text?(acesso.matricula_discente)
end

# troca de catraca pela tela e confere que só aparecem os acessos dela.
Dado("que estou visualizando o histórico da {string}") do |nome_catraca|
  @catraca_1 = criar_catraca(nome_catraca)
  @catraca_2 = criar_catraca("Catraca 02")
  @acesso_1 = criar_acesso(@catraca_1)
  @acesso_2 = criar_acesso(@catraca_2)
  visit catraca_acessos_path(@catraca_1)
end

Quando("seleciono a {string} para gerenciar") do |nome_catraca|
  visit restaurantes_path
  within("li", text: nome_catraca) do
    click_link "Histórico"
  end
  @catraca = catraca_por_nome(nome_catraca)
end

Então("devo visualizar apenas os registros da {string}") do |nome_catraca|
  acesso_esperado = acessos_por_catraca(nome_catraca).last
  exigir_texto(acesso_esperado.matricula_discente)

  (@acessos_por_catraca || {}).each do |nome, acessos|
    next if nome == nome_catraca

    acessos.each do |acesso|
      raise "O acesso da catraca #{nome} apareceu no histórico" if page.has_text?(acesso.matricula_discente)
    end
  end
end

# abre o histórico vazio e espera a mensagem de que ainda não há acessos.
Dado("que não existem acessos registrados na catraca selecionada") do
  @catraca = criar_catraca("Catraca sem acessos")
end

Então("devo visualizar uma mensagem informando que não há registros") do
  exigir_texto("Não há acessos para os filtros selecionados.")
end

# confere que uma tentativa negada aparece, mas não entra no total debitado.
Dado("que uma tentativa de acesso na catraca selecionada foi negada por saldo insuficiente") do
  @catraca = criar_catraca("Catraca 01")
  @acesso = criar_acesso(
    @catraca,
    status_acesso: :bloqueado,
    motivo_negativa: "Saldo insuficiente",
    matricula_discente: "MAT-NEGADO"
  )
end

Então("devo visualizar essa tentativa no histórico") do
  exigir_texto(@acesso.matricula_discente)
end

Então("o status do acesso deve ser {string}") do |status|
  exigir_texto(status.capitalize)
end

Então("o motivo da negativa deve ser {string}") do |motivo|
  exigir_texto(motivo)
end

Então("nenhum valor da tentativa deve ser contabilizado no total debitado") do
  total_zero = ActionController::Base.helpers.number_to_currency(0, unit: "R$ ")
  exigir_texto("Total debitado hoje: #{total_zero}")
end

# prepara acessos em turnos diferentes e testa o filtro de turno.
Dado("que existem acessos registrados em diferentes turnos na catraca selecionada") do
  @catraca = criar_catraca("Catraca 01")
  @acessos_por_turno = {
    "Café da manhã" => criar_acesso(@catraca, turno: "Café da manhã", matricula_discente: "MAT-CAFE"),
    "Almoço" => criar_acesso(@catraca, turno: "Almoço", matricula_discente: "MAT-ALMOCO")
  }
end

Quando("filtro o histórico pelo {string}") do |filtro|
  @turno_filtrado = filtro.split(" do dia ").first
  visit catraca_acessos_path(@catraca)
  select @turno_filtrado, from: "Turno"
  fill_in "Data", with: Date.current.iso8601
  click_button "Filtrar"
end

Então("devo visualizar apenas os acessos registrados no turno selecionado") do
  acesso_esperado = @acessos_por_turno.fetch(@turno_filtrado)
  exigir_texto(acesso_esperado.matricula_discente)

  (@acessos_por_turno.keys - [@turno_filtrado]).each do |turno|
    raise "Acesso do turno #{turno} apareceu no filtro" if page.has_text?(@acessos_por_turno.fetch(turno).matricula_discente)
  end
end

# mistura acessos liberados e bloqueados e confere o filtro de status.
Dado("que existem acessos liberados e negados na catraca selecionada") do
  @catraca = criar_catraca("Catraca 01")
  @acesso_liberado = criar_acesso(@catraca, status_acesso: :liberado, matricula_discente: "MAT-LIBERADO")
  @acesso_bloqueado = criar_acesso(
    @catraca,
    status_acesso: :bloqueado,
    motivo_negativa: "Saldo insuficiente",
    matricula_discente: "MAT-BLOQUEADO"
  )
end

Quando("filtro o histórico pelo status {string}") do |status|
  visit catraca_acessos_path(@catraca)
  select status.capitalize, from: "Status do acesso"
  click_button "Filtrar"
end

Então("devo visualizar apenas os acessos com status {string}") do |status|
  acesso_esperado = status == "bloqueado" ? @acesso_bloqueado : @acesso_liberado
  acesso_oculto = status == "bloqueado" ? @acesso_liberado : @acesso_bloqueado
  exigir_texto(acesso_esperado.matricula_discente)
  raise "Acesso com status incorreto apareceu" if page.has_text?(acesso_oculto.matricula_discente)
end

def criar_catraca(nome)
  @catracas_por_nome ||= {}
  @catracas_por_nome[nome] ||= begin
    numero = @catracas_por_nome.length + 1
    codigo = format("%02d", numero)
    nome_restaurante = ["RU Darcy Ribeiro", "RU Gama", "RU Ceilândia"].fetch(numero - 1)
    restaurante = Restaurante.create!(
      codigo: codigo,
      nome: nome_restaurante,
      capacidade_por_hora: 100,
      total_pisos: 3
    )
    restaurante.catracas.create!(
      codigo: "CAT-#{codigo}",
      nome: nome,
      piso: 1,
      status: :online
    )
  end
end

def catraca_por_nome(nome)
  @catracas_por_nome.fetch(nome)
end

def criar_acesso(catraca, **atributos)
  @acessos_por_catraca ||= Hash.new { |hash, key| hash[key] = [] }
  numero = @acessos_por_catraca[catraca.nome].length + 1
  acesso = catraca.acessos.create!({
    matricula_discente: "MAT-#{catraca.codigo.last(2)}-#{format('%02d', numero)}",
    turno: "Almoço",
    modo_validacao: "Cartão",
    tarifa: 2.50,
    status_acesso: :liberado,
    status_catraca: catraca.status,
    ocorrido_em: Time.current.change(hour: 12, min: 0)
  }.merge(atributos))
  @acessos_por_catraca[catraca.nome] << acesso
  acesso
end

def acessos_por_catraca(nome)
  (@acessos_por_catraca || {}).fetch(nome, [])
end

def exigir_texto(texto)
  raise "Não encontrei na página: #{texto}" unless page.has_text?(texto)
end
