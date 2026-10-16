# language: pt

Funcionalidade: Validação de entrada na catraca do RU
  Como aplicação de controle
  Quero ler a identificação do aluno, verificar se há saldo, enviar o comando de liberação para a catraca e efetuar o débito da refeição no momento da passagem
  Para garantir o controle de acesso e a cobrança correta no Restaurante Universitário

  Cenário: Validar entrada de estudante do Grupo I com isenção integral (Caminho Feliz)
    Dado que o estudante pertence ao "Grupo I" com benefício de isenção integral
    E o estudante possui saldo de R$ 0,00
    Quando a identificação válida do estudante é lida na catraca
    E o estudante gira a catraca
    Então a catraca deve ser liberada sem exigir saldo
    E o saldo do estudante deve permanecer R$ 0,00
    E o acesso deve ser registrado como isento no turno atual

  Esquema do Cenário: Validar entrada com débito correto por turno e grupo tarifário (Caminho Feliz)
    Dado que o turno atual é "<turno>" e a tarifa para o "<grupo>" é de R$ <tarifa>
    E o aluno possui saldo de R$ <saldo_inicial>
    Quando a identificação válida do aluno é lida na catraca
    E o aluno gira a catraca
    Então a catraca deve ser liberada
    E o saldo do aluno deve ser debitado para R$ <saldo_final>
    E o acesso deve ser registrado no turno atual

    Exemplos:
      | grupo     | turno          | tarifa | saldo_inicial | saldo_final |
      | Grupo II  | Café da manhã  | 2,00   | 5,00          | 3,00        |
      | Grupo II  | Almoço         | 4,50   | 10,00         | 5,50        |
      | Grupo II  | Jantar         | 4,50   | 4,50          | 0,00        |
      | Grupo IV  | Café da manhã  | 1,50   | 3,00          | 1,50        |
      | Grupo IV  | Almoço         | 2,50   | 5,00          | 2,50        |
      | Grupo IV  | Jantar         | 2,50   | 2,50          | 0,00        |
      | Grupo III | Café da manhã  | 7,05   | 10,00         | 2,95        |
      | Grupo III | Almoço         | 15,20  | 20,00         | 4,80        |
      | Grupo III | Jantar         | 15,20  | 15,20         | 0,00        |

  Esquema do Cenário: Impedir entrada de grupo pagante com saldo insuficiente no turno (Caminho Triste)
    Dado que o turno atual é "<turno>" e a tarifa para o "<grupo>" é de R$ <tarifa>
    E o aluno possui saldo de R$ <saldo_atual>
    Quando a identificação do aluno é lida na catraca
    Então a catraca deve permanecer bloqueada
    E o visor da catraca deve exibir "Saldo insuficiente"
    E o saldo do aluno deve se manter em R$ <saldo_atual>

    Exemplos:
      | grupo     | turno          | tarifa | saldo_atual |
      | Grupo II  | Café da manhã  | 2,00   | 1,99        |
      | Grupo II  | Almoço         | 4,50   | 4,49        |
      | Grupo II  | Jantar         | 4,50   | 0,00        |
      | Grupo IV  | Café da manhã  | 1,50   | 0,00        |
      | Grupo IV  | Almoço         | 2,50   | 2,00        |
      | Grupo IV  | Jantar         | 2,50   | 0,00        |
      | Grupo III | Café da manhã  | 7,05   | 5,00        |
      | Grupo III | Almoço         | 15,20  | 10,00       |
      | Grupo III | Jantar         | 15,20  | 0,00        |


  Cenário: Impedir entrada com identificação não cadastrada (Caminho Triste)
    Dado que a identificação "999999999" não existe na base de dados
    Quando a identificação "999999999" é lida na catraca
    Então a catraca deve permanecer bloqueada
    E o visor da catraca deve exibir "Usuário não encontrado"

  Cenário: Cancelar liberação por timeout sem giro físico da catraca (Caminho Triste)
    Dado que o aluno do "Grupo II" possui saldo de R$ 10,00
    E a catraca foi liberada com timeout de 5 segundos
    Quando passam-se 5 segundos sem que o sensor de giro seja acionado
    Então a catraca volta a ser bloqueada
    E nenhum débito deve ser efetuado mantendo o saldo em R$ 10,00
    E o acesso deve ser cancelado

  Cenário: Impedir dupla entrada no mesmo turno por anti-passback (Caminho Triste)
    Dado que o aluno possui saldo de R$ 20,00
    E o aluno já possui uma passagem registrada no turno "Almoço" de hoje
    Quando o aluno tenta validar a entrada novamente no mesmo turno "Almoço"
    Então a catraca deve permanecer bloqueada
    E o visor da catraca deve exibir "Refeição já utilizada neste turno"
    E o saldo do aluno deve se manter em R$ 20,00
