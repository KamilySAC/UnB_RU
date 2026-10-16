# language: pt

Funcionalidade: Exportação em PDF do Histórico do Estudante
  Como estudante
  Quero poder exportar meu Extrato e Histórico de Refeições como PDF
  Para poder controlar melhor as minhas finanças

  Cenário: Exportar histórico e extrato do mês atual em PDF com sucesso (Caminho Feliz)
    Dado que estou autenticado como estudante
    E possuo movimentações registradas no mês atual
    Quando solicito a exportação do meu histórico em PDF
    Então o arquivo "historico_estudante.pdf" deve ser gerado para download
    E o relatório deve apresentar automaticamente apenas as movimentações do mês atual
    E deve exibir os dados do discente, o saldo atual e os totais consumidos e recarregados no mês

  Cenário: Desconsiderar movimentações de meses anteriores na exportação (Caminho Feliz)
    Dado que estou autenticado como estudante
    E possuo movimentações registradas no mês atual e em meses anteriores
    Quando solicito a exportação do meu histórico em PDF
    Então o arquivo PDF gerado não deve conter os registros de meses anteriores
    E os totais calculados devem contabilizar exclusivamente o mês atual

  Cenário: Tentar exportar sem movimentações no mês atual (Caminho Triste)
    Dado que estou autenticado como estudante
    E não possuo movimentações registradas no mês atual
    Quando tento exportar o histórico em PDF
    Então nenhum arquivo deve ser baixado
    E devo visualizar a mensagem "Não há movimentações registradas no mês atual"
