# language: pt

Funcionalidade: Cadastrar estudante
    Como estudante
    Quero me cadastrar no sistema utilizando minha matrícula
    Para que eu possa criar minha conta de acesso ao RU

    Cenário: Cadastro com informações válidas (Caminho Feliz)
        Dado que informei corretamente minha matrícula
        E inseri meu nome completo
        E inseri senhas válidas iguais
        E ainda não possuo cadastro
        Quando tento realizar meu cadastro
        Então minha conta deve ser criada com sucesso
        E uma mensagem informando a confirmação deve ser exibida

    Cenário: Impedir cadastro com senhas diferentes (Caminho Triste)
        Dado que informei duas senhas diferentes
        E preenchi corretamente o nome e a matrícula
        Quando tento realizar meu cadastro
        Então minha conta não deve ser criada
        E uma mensagem informando que as senhas não são iguais deve ser exibida

    Cenário: Impedir cadastro com preenchimento incompleto (Caminho Triste)
        Dado que deixei pelo menos um campo obrigatório sem preencher
        Quando tento realizar meu cadastro
        Então minha conta não deve ser criada
        E uma mensagem informando que todos os campos devem ser preenchidos deve ser exibida

    Cenário: Impedir cadastro com matrícula já cadastrada (Caminho Triste)
        Dado que informei uma matrícula que já foi cadastrada
        Quando tento realizar meu cadastro
        Então minha conta não deve ser criada
        E uma mensagem informando que a matrícula já foi cadastrada deve ser exibida
