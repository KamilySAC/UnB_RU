# language: pt

Funcionalidade: Validação de entrada na catraca do RU
  Como aplicação de controle
  Quero ler a identificação do usuário, verificar o perfil tarifário e o saldo, enviar o comando de liberação para a catraca e efetuar o débito da refeição no momento da passagem
  Para garantir o controle de acesso e a cobrança correta no Restaurante Universitário

  Cenário: Validar entrada de estudante do Grupo I com subsídio integral de 100% (Caminho Feliz)
    Dado que o estudante pertence ao "Grupo I" com benefício de isenção integral
    E o estudante possui saldo de R$ 0,00
    Quando a identificação válida do estudante é lida na catraca
    E o estudante gira a catraca
    Então a catraca deve ser liberada sem exigir saldo
    E o saldo do estudante deve permanecer R$ 0,00
    E o acesso deve ser registrado como isento no turno atual

  Cenário: Validar entrada de estudante do Grupo II no almoço com saldo suficiente (Caminho Feliz)
    Dado que o estudante pertence ao "Grupo II" cuja refeição de almoço custa R$ 4,50
    E o estudante possui saldo de R$ 10,00
    Quando a identificação válida do estudante é lida na catraca
    E o estudante gira a catraca
    Então a catraca deve ser liberada
    E o saldo do estudante deve ser debitado para R$ 5,50
    E o acesso deve ser registrado no turno atual

  Cenário: Validar entrada com saldo exato no valor de borda para o Grupo II (Caminho Feliz)
    Dado que o estudante pertence ao "Grupo II" cuja refeição de almoço custa R$ 4,50
    E o estudante possui saldo de R$ 4,50
    Quando a identificação válida do estudante é lida na catraca
    E o estudante gira a catraca
    Então a catraca deve ser liberada
    E o saldo do estudante deve ser debitado para R$ 0,00
    E o acesso deve ser registrado no turno atual

  Cenário: Validar entrada de estudante cotista do Grupo IV no almoço (Caminho Feliz)
    Dado que o estudante pertence ao "Grupo IV" cuja refeição de almoço custa R$ 2,50
    E o estudante possui saldo de R$ 5,00
    Quando a identificação válida do estudante é lida na catraca
    E o estudante gira a catraca
    Então a catraca deve ser liberada
    E o saldo do estudante deve ser debitado para R$ 2,50
    E o acesso deve ser registrado no turno atual

  Cenário: Validar entrada de usuário do Grupo III no almoço com tarifa integral (Caminho Feliz)
    Dado que o usuário pertence ao "Grupo III" cuja refeição de almoço custa R$ 15,20
    E o usuário possui saldo de R$ 20,00
    Quando a identificação válida do usuário é lida na catraca
    E o usuário gira a catraca
    Então a catraca deve ser liberada
    E o saldo do usuário deve ser debitado para R$ 4,80
    E o acesso deve ser registrado no turno atual

  Cenário: Validar entrada no café da manhã para estudante do Grupo II (Caminho Feliz)
    Dado que o turno atual é "Café da manhã" e a refeição para o "Grupo II" custa R$ 2,00
    E o estudante possui saldo de R$ 5,00
    Quando a identificação válida do estudante é lida na catraca
    E o estudante gira a catraca
    Então a catraca deve ser liberada
    E o saldo do estudante deve ser debitado para R$ 3,00
    E o acesso deve ser registrado no turno atual

  Cenário: Impedir entrada do Grupo II com saldo insuficiente por 1 centavo (Caminho Triste)
    Dado que o estudante pertence ao "Grupo II" cuja refeição de almoço custa R$ 4,50
    E o estudante possui saldo de R$ 4,49
    Quando a identificação do estudante é lida na catraca
    Então a catraca deve permanecer bloqueada
    E o visor da catraca deve exibir "Saldo insuficiente"
    E o saldo do estudante deve se manter em R$ 4,49

  Cenário: Impedir entrada com saldo zerado para pagante do Grupo II (Caminho Triste)
    Dado que o estudante pertence ao "Grupo II" cuja refeição de almoço custa R$ 4,50
    E o estudante possui saldo de R$ 0,00 sem benefício de isenção
    Quando a identificação do estudante é lida na catraca
    Então a catraca deve permanecer bloqueada
    E o visor da catraca deve exibir "Saldo insuficiente"

  Cenário: Impedir entrada com identificação não cadastrada (Caminho Triste)
    Dado que a identificação "999999999" não existe na base de dados
    Quando a identificação "999999999" é lida na catraca
    Então a catraca deve permanecer bloqueada
    E o visor da catraca deve exibir "Usuário não encontrado"

  Cenário: Impedir entrada com identificação corrompida ou formato inválido (Caminho Triste)
    Dado que o leitor recebe caracteres inválidos "ABC-123"
    Quando a identificação malformada é lida na catraca
    Então a catraca deve permanecer bloqueada
    E o visor da catraca deve exibir "Erro de leitura / Identificação inválida"

  Cenário: Impedir entrada de aluno com vínculo acadêmico inativo (Caminho Triste)
    Dado que o aluno possui matrícula trancada com cadastro inativo
    E o aluno possui saldo de R$ 20,00
    Quando a matrícula do aluno inativo é lida na catraca
    Então a catraca deve permanecer bloqueada
    E o visor da catraca deve exibir "Cadastro inativo"
    E o saldo do aluno não deve ser alterado

  Cenário: Cancelar acesso por timeout ou desistência de passagem (Caminho Triste)
    Dado que o estudante do "Grupo II" possui saldo de R$ 10,00
    E a catraca foi liberada com timeout de 5 segundos
    Quando passam-se 5 segundos sem que o sensor de giro seja acionado
    Então a catraca volta a ser bloqueada
    E nenhum débito deve ser efetuado mantendo o saldo em R$ 10,00
    E o acesso deve ser cancelado

  Cenário: Tratar leitura duplicada antes do giro da catraca (Caminho Triste)
    Dado que o estudante do "Grupo II" possui saldo de R$ 15,00
    E a catraca já foi liberada e aguarda o giro
    Quando o estudante encosta o cartão novamente antes de girar a catraca
    Então o sistema deve ignorar a segunda leitura
    E deve debitar apenas uma refeição de R$ 4,50 quando o estudante girar a catraca

  Cenário: Impedir dupla entrada no mesmo turno por anti-passback (Caminho Triste)
    Dado que o estudante possui saldo de R$ 20,00
    E o estudante já possui uma passagem registrada no turno "Almoço" de hoje
    Quando o estudante tenta validar a entrada novamente no mesmo turno "Almoço"
    Então a catraca deve permanecer bloqueada
    E o visor da catraca deve exibir "Refeição já utilizada neste turno"
    E o saldo do estudante deve se manter em R$ 20,00

