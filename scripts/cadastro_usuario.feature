# language: pt

Funcionalidade: Cadastrar estudante
    Como estudante
    Quero me cadastrar no sistema utilizando minha matrícula
    Para que eu possa criar minha conta de acesso ao RU

    Cenário: Cadastro com matrícula válida (Caminho Feliz)
        Dado que informei corretamente minha matrícula
        E sou um estudante da UnB
        E minha matrícula ainda não está cadastrada
        Quando tento realizar meu cadastro
        Então minha conta deve ser criada com sucesso
        E uma mensagem de confirmação deve ser exibida

    Cenário: Impedir cadastro com matrícula não encontrada (Caminho Triste)
        Dado que informei uma matrícula que não existe
        Quando tento realizar meu cadastro
        Então minha conta não deve ser criada
        E uma mensagem informando que a matrícula não foi encontrada deve ser exibida

    Cenário: Impedir cadastro com matrícula já cadastrada (Caminho Triste)
        Dado que informei uma matrícula que já foi cadastrada
        Quando tento realizar meu cadastro
        Então minha conta não deve ser criada
        E uma mensagem informando que a matrícula já foi cadastrada deve ser exibida