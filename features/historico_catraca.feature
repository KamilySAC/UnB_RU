# language: pt

Funcionalidade: Gerenciar restaurantes e catracas
  Como funcionário
  Quero visualizar na aplicação de controle o histórico de todos os acessos registrados apenas na catraca que estou gerenciando no momento
  Para realizar auditorias ou conferências locais de fluxo.

Cenário: Visualizar o histórico da catraca selecionada
  Dado que existem acessos registrados na "Catraca 01"
  Quando acesso a opção "Histórico Local"
  Então devo visualizar os acessos registrados nessa catraca
  E cada registro deve apresentar horário, matricula do discente, modo de validação, tarifa e status da catraca.

Cenário: Não visualizar acessos de outra catraca
  Dado que existem acessos registrados nas catracas "Catraca 01" e "Catraca 02"
  Quando acesso o histórico da "Catraca 01"
  Então não devo visualizar registros da "Catraca 02"

Cenário: Atualizar o histórico ao trocar de catraca
  Dado que estou visualizando o histórico da "Catraca 01"
  Quando seleciono a "Catraca 02" para gerenciar
  Então devo visualizar apenas os registros da "Catraca 02"

Cenário: Visualizar histórico sem registros
  Dado que não existem acessos registrados na catraca selecionada
  Quando acesso a opção "Histórico Local"
  Então devo visualizar uma mensagem informando que não há registros

Cenário: Exibir uma tentativa de acesso negada no histórico
  Dado que uma tentativa de acesso na catraca selecionada foi negada por saldo insuficiente
  Quando acesso a opção "Histórico Local"
  Então devo visualizar essa tentativa no histórico
  E o status do acesso deve ser "bloqueado"
  E o motivo da negativa deve ser "Saldo insuficiente"
  E nenhum valor deve ser debitado do discente

Cenário: Filtrar o histórico por turno
  Dado que existem acessos registrados em diferentes turnos na catraca selecionada
  Quando filtro o histórico pelo "Almoço do dia x"
  Então devo visualizar apenas os acessos registrados no turno selecionado

Cenário: Filtrar o histórico por status
  Dado que existem acessos liberados e negados na catraca selecionada
  Quando filtro o histórico pelo status "bloqueado"
  Então devo visualizar apenas os acessos com status "bloqueado"



