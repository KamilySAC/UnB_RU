# language: pt

Funcionalidade: Autenticação do fiscal no aplicativo (US07)
  Como funcionário do restaurante
  Quero fazer login no aplicativo
  Para autenticar minha sessão e operar o sistema de forma segura

  Contexto:
    Dado que existe o fiscal "Fulano D." com matrícula SIAPE "2948102" e senha "Senha@123"
    E que o fiscal "Fulano D." também possui o usuário "fulano.fiscal"

  Cenário: Login com credenciais válidas (Caminho Feliz)
    Dado que estou na tela "Autenticação do Operador"
    Quando informo a matrícula SIAPE "2948102" e a senha "Senha@123"
    E clico em "Entrar no Sistema"
    Então devo ser autenticado
    E devo ser direcionado para a tela "Configuração de Ponto de Acesso"

  Cenário: Login com os dois tipos de identificador aceitos (Caminho Feliz)
    Dado que estou na tela "Autenticação do Operador"
    Quando informo o identificador  "2948102" e a senha "Senha@123"
    E clico em "Entrar no Sistema"
    Então devo ser autenticado
    E devo ser direcionado para a tela "Configuração de Ponto de Acesso"


  Cenário: Identificação do funcionário após o login (Caminho Feliz)
    Dado que me autentiquei como "Fulano D." com a matrícula SIAPE "2948102"
    Quando acesso a tela "Configuração de Ponto de Acesso"
    Então devo ver "Fulano D." e a matrícula "2948102" identificados como funcionário autenticado

  Cenário: Alternar a visibilidade da senha (Caminho Feliz)
    Dado que estou na tela "Autenticação do Operador"
    E informei a senha "Senha@123"
    Quando clico no ícone de visualizar senha
    Então a senha deve ser exibida em texto
    Quando clico novamente no ícone de visualizar senha
    Então a senha deve voltar a ficar oculta

  Cenário: Sessão autenticada dá acesso às telas do aplicativo (Caminho Feliz)
    Dado que estou autenticado como fiscal
    Então devo poder acessar "Configuração de Ponto", "Terminal de Validação" e "Histórico Local"

  Cenário: Logout encerra a sessão (Caminho Feliz)
    Dado que estou autenticado como fiscal
    Quando faço logout
    Então minha sessão deve ser encerrada
    E devo ser direcionado para a tela "Autenticação do Operador"

  Cenário: Impedir login com senha incorreta (Caminho Triste)
    Dado que estou na tela "Autenticação do Operador"
    Quando informo a matrícula SIAPE "2948102" e a senha "SenhaErrada"
    E clico em "Entrar no Sistema"
    Então não devo ser autenticado
    E devo ser informado que as credenciais são inválidas

  Cenário: Impedir login com identificador não cadastrado (Caminho Triste)
    Dado que estou na tela "Autenticação do Operador"
    Quando informo a matrícula SIAPE "0000000" e a senha "Senha@123"
    E clico em "Entrar no Sistema"
    Então não devo ser autenticado
    E devo ser informado que as credenciais são inválidas

    Cenário: Impedir login sem informar a matrícula ou usuário (Caminho Triste)
    Dado que estou na tela "Autenticação do Operador"
    Quando deixo o campo de matrícula ou usuário vazio e informo a senha "Senha@123"
    E clico em "Entrar no Sistema"
    Então não devo ser autenticado
    E devo ser informado que a matrícula ou usuário é obrigatório

  Cenário: Impedir login sem informar a senha (Caminho Triste)
    Dado que estou na tela "Autenticação do Operador"
    Quando informo a matrícula SIAPE "2948102" e deixo a senha vazia
    E clico em "Entrar no Sistema"
    Então não devo ser autenticado
    E devo ser informado que a senha é obrigatória

 
 