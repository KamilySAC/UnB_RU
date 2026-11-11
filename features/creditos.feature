# language: pt

Funcionalidade: Adicionar créditos à conta

  Contexto:
    Dado que estou logado como estudante
    E meu saldo atual é de R$ 0,00

  Cenário: Adicionar créditos com sucesso via PIX
    Quando eu escolho a opção de pagamento via PIX
    E eu gero um QR Code de recarga no valor de R$ x
    E eu realizo o pagamento do PIX
    Então meu saldo deve ser atualizado para +R$ x
    E uma mensagem de sucesso deve ser exibida

  Cenário: Adicionar créditos com sucesso via cartão de crédito
    Quando eu escolho a opção de pagamento via cartão de crédito
    E eu insiro os dados de um cartão de crédito válido
    E eu confirmo a recarga no valor de R$ x
    Então meu saldo deve ser atualizado para + R$ x
    E uma mensagem de sucesso deve ser exibida

  Cenário: Tentar adicionar créditos via cartão de crédito com dados inválidos
    Quando eu escolho a opção de pagamento via cartão de crédito
    E eu insiro dados inválidos do cartão de crédito
    E eu tento confirmar a recarga
    Então uma mensagem de erro deve ser exibida
    E meu saldo não deve ser alterado
