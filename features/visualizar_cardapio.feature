# language: pt

Funcionalidade: Visualizar cardápio da refeição atual
    Como estudante
    Quero visualizar o cardápio da refeição que está sendo servida agora
    Para conhecer as opções de cardápio padrão, ovolactovegetariano e vegetariano estrito

    Cenário: Visualizar as opções do cardápio da refeição atual (Caminho Feliz)
        Dado que estou logado na plataforma
        E existe um cardápio cadastrado para a refeição atual
        Quando acesso a página inicial
        Então devo visualizar o nome do restaurante e seu horário de funcionamento
        E devo visualizar as opções de cardápio padrão, ovolactovegetariano e vegetariano estrito na seção de cardápio
        E cada opção deve apresentar prato principal, guarnição, salada, sobremesa e bebida
    
    Cenário: Informar que não há cardápio cadastrado para a refeição atual (Caminho Triste)
        Dado que estou logado na plataforma
        E não existe cardápio cadastrado para a refeição atual
        Quando acesso a página inicial
        Então a seção de cardápio deve apresentar uma mensagem informando a indisponibilidade de cardápio