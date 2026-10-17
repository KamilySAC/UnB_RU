# language: pt

Funcionalidade: Histórico global de acessos do campus
  Como administrador
  Quero visualizar o histórico completo de todos os acessos do campus,
  podendo filtrar e agrupar os dados por restaurante e por catraca específica
  Para ter uma visão gerencial de toda a operação

  Contexto:
    Dado que estou autenticado como administrador
    E existem os restaurantes "Restaurante 1" e "Restaurante 2" com catracas cadastradas
    E existem acessos registrados nas catracas desses restaurantes

  Cenário: Visualizar o histórico completo de acessos do campus (Caminho Feliz)
    Quando acesso o histórico global de acessos
    Então devo ver os acessos de todos os restaurantes e de todas as catracas do campus
    E cada acesso deve exibir horário, matrícula do estudante, tarifa e status da catraca

  Cenário: Visualizar o total consolidado do campus (Caminho Feliz)
    Quando acesso o histórico global de acessos
    Então devo ver o total de acessos e a arrecadação bruta do campus
    E o total consolidado deve ser a soma dos valores de todos os restaurantes

  Cenário: Visualizar acessos bloqueados com o motivo (Caminho Feliz)
    Dado que houve um acesso bloqueado por "Saldo Insuficiente"
    E houve um acesso bloqueado por "Janela Expirada"
    Quando acesso o histórico global de acessos
    Então esses acessos devem aparecer com tarifa "R$ 0,00"
    E o motivo do bloqueio deve estar visível em cada um

  Cenário: Filtrar o histórico por restaurante (Caminho Feliz)
    Dado que estou no histórico global de acessos
    Quando filtro por "Restaurante 1"
    Então devo ver apenas os acessos do "Restaurante 1"

  Cenário: Filtrar o histórico por catraca específica (Caminho Feliz)
    Dado que estou no histórico global de acessos
    E filtro por "Restaurante 1"
    Quando filtro pela catraca "Catraca 04"
    Então devo ver apenas os acessos da "Catraca 04" do "Restaurante 1"

  Cenário: Agrupar o histórico por restaurante (Caminho Feliz)
    Dado que estou no histórico global de acessos
    Quando agrupo os dados por restaurante
    Então devo ver uma linha para cada restaurante
    E cada linha deve exibir acessos, pontualidade e arrecadação bruta
    E devo ver o total consolidado de todos os restaurantes

  Cenário: Agrupar o histórico por catraca (Caminho Feliz)
    Dado que estou no histórico global de acessos
    Quando agrupo os dados por catraca
    Então devo ver uma linha para cada catraca
    E cada linha deve exibir passagens  e total debitado


  Cenário: Informar que não há acessos para o filtro aplicado (Caminho Triste)
    Dado que estou no histórico global de acessos
    E a "Catraca 05" não possui acessos registrados
    Quando filtro pela catraca "Catraca 05"
    Então nenhum acesso deve ser exibido
    E devo ser informado que não há acessos para os filtros selecionados

  Cenário: Impedir filtro por catraca que não pertence ao restaurante selecionado (Caminho Triste)
    Dado que estou no histórico global de acessos
    E a "Catraca 04" pertence ao "Restaurante 1"
    Quando filtro por "Restaurante 2"
    Então a "Catraca 04" não deve estar disponível como opção de filtro

  Cenário: Impedir que o fiscal acesse o histórico global do campus (Caminho Triste)
    Dado que estou autenticado como fiscal no aplicativo
    Quando tento acessar o histórico global de acessos
    Então não devo poder visualizar acessos de outras catracas
    E devo ver apenas o histórico local da minha catraca

