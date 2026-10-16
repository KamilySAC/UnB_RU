# language: pt

Funcionalidade: Visualizar extrato de recargas e histórico de refeições
  Como estudante
  Eu quero visualizar meu extrato de recargas e histórico de refeições
  Para ter controle sobre meus gastos e utilizações

  Contexto:
    Dado que estou autenticado como estudante
    E possuo movimentações registradas na minha conta

  Cenário: Visualizar extrato de recargas com sucesso
    Quando eu acesso a opção "Extrato de recargas"
    Então devo visualizar a lista de recargas realizadas
    E cada recarga deve apresentar data, valor e forma de pagamento
    E devo visualizar o total recarregado no período

  Cenário: Visualizar histórico de refeições com sucesso
    Quando eu acesso a opção "Histórico de refeições"
    Então devo visualizar a lista de refeições realizadas
    E cada refeição deve apresentar data, restaurante e valor debitado
    E devo visualizar o total gasto no período

  Cenário: Visualizar extrato e histórico em um único painel
    Quando eu acesso a opção "Meus gastos"
    Então devo visualizar as abas "Recargas" e "Refeições"
    E ao selecionar "Recargas" devo ver o extrato de recargas
    E ao selecionar "Refeições" devo ver o histórico de refeições

  Cenário: Filtrar movimentações por período
    Quando eu acesso a opção "Histórico de refeições"
    E seleciono o período de "01/10/2026" a "31/10/2026"
    Então devo visualizar apenas as refeições realizadas nesse período
    E o total gasto deve considerar apenas o período filtrado

  Cenário: Visualizar detalhes de uma recarga
    Quando eu acesso a opção "Extrato de recargas"
    E seleciono uma recarga da lista
    Então devo visualizar os detalhes da recarga
    E os detalhes devem conter data, valor, forma de pagamento e status

  Cenário: Visualizar histórico de refeições vazio
    Dado que não possuo refeições registradas no período
    Quando eu acesso a opção "Histórico de refeições"
    Então devo visualizar uma mensagem informando que não há refeições no período
    E o total gasto deve ser R$ 0,00

  Cenário: Não visualizar movimentações de outro estudante
    Quando eu acesso a opção "Extrato de recargas"
    Então devo visualizar apenas as minhas recargas
    E não devo visualizar recargas de outros estudantes
