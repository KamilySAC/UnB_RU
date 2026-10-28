# language: pt

Funcionalidade: Gerenciar restaurantes e catracas
  Como administrador
  Quero gerenciar restaurantes e suas catracas
  Para que os funcionários possam selecioná-los na Aplicação de Controle

  Cenário: Cadastrar um restaurante (Caminho Feliz)
    Dado que estou autenticado como administrador
    Quando cadastro o restaurante "RU Darcy Ribeiro"
    Então o restaurante "RU Darcy Ribeiro" deve aparecer na lista de restaurantes
    E deve estar disponível na Aplicação de Controle

  Cenário: Adicionar uma catraca a um restaurante (Caminho Feliz)
    Dado que estou autenticado como administrador
    E existe o restaurante "RU Darcy Ribeiro"
    Quando adiciono a catraca "Catraca 01" ao restaurante "RU Darcy Ribeiro"
    Então a catraca "Catraca 01" deve aparecer nos detalhes do restaurante
    E deve estar disponível na Aplicação de Controle para esse restaurante

  Cenário: Editar um restaurante (Caminho Feliz)
    Dado que estou autenticado como administrador
    E existe o restaurante "RU Darcy Ribeiro"
    Quando altero o nome do restaurante para "RU Gama"
    Então o restaurante deve aparecer como "RU Gama" na lista

  Cenário: Editar uma catraca (Caminho Feliz)
    Dado que estou autenticado como administrador
    E existe a catraca "Catraca 01" associada ao restaurante "RU Darcy Ribeiro"
    Quando altero o estado da catraca para "Offline"
    Então a catraca deve aparecer como "Offline" nos detalhes do restaurante

  Cenário: Impedir cadastro de restaurante sem nome (Caminho Triste)
    Dado que estou autenticado como administrador
    Quando tento cadastrar um restaurante sem informar o nome
    Então o restaurante não deve ser cadastrado
    E devo ser informado que o nome é obrigatório

  Cenário: Impedir cadastro de restaurante com nome já utilizado (Caminho Triste)
    Dado que estou autenticado como administrador
    E existe o restaurante "RU Darcy Ribeiro"
    Quando tento cadastrar outro restaurante chamado "RU Darcy Ribeiro"
    Então o novo restaurante não deve ser cadastrado
    E devo ser informado que já existe um restaurante com esse nome

  Cenário: Impedir que funcionário cadastre um restaurante (Caminho Triste)
    Dado que estou autenticado como funcionário
    Quando tento acessar o cadastro de restaurantes
    Então não devo poder cadastrar restaurantes

  Cenário: Impedir adição de catraca a restaurante inexistente (Caminho Triste)
    Dado que estou autenticado como administrador
    E não existe o restaurante "RU Inexistente"
    Quando tento adicionar a catraca "Catraca 01" ao restaurante "RU Inexistente"
    Então a catraca não deve ser cadastrada


