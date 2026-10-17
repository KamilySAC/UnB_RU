# Wiki - Sprint 1

**Projeto:** UnB-Ru

## Integrantes

| Nome                            | Matrícula | Papel         |
| ------------------------------- | --------- | ------------- |
| Ana Sarah Nagata                | 242023176 | Scrum Master  |
| Kamily Silva Andrade Crispim    | 242009945 | Product Owner |
| João Pedro Rabelo do Nascimento | 241036160 | Desenvolvedor |
| Maria Luiza Macedo Bezerra      | 221010372 | Desenvolvedor |
| Arthur Santos Almeida           | 242009990 | Desenvolvedor |

## Regras de Negócio

### Issue Gestão de Restaurantes e Catracas

- Apenas administradores podem gerenciar restaurantes e catracas
- Restaurantes cadastrados aparecem na lista e ficam disponíveis na Aplicação de Controle.
- Não pode haver dois restaurantes ativos com o mesmo nome.
- Não é possível adicionar catracas a restaurantes inexistentes.
- Administradores podem editar o nome de um restaurante e o estado de uma catraca.
- Funcionários não podem cadastrar ou gerenciar restaurantes.

### Issue Validação de Entrada na Catraca

- A catraca só valida a entrada se o restaurante estiver aberto no horário de funcionamento do turno atual (Café da manhã, Almoço ou Jantar).
- A catraca deve estar ativa; se estiver em manutenção ou offline, a passagem não é liberada.
- A identificação do usuário deve estar cadastrada, em formato válido e com vínculo ativo.
- O usuário só pode utilizar uma refeição por turno.
- O sistema calcula a tarifa conforme o perfil do usuário:
  - Grupo I (Subsídio Integral / 100% gratuito). Tarifa: R$ 0,00;
  - Grupo II (Graduação, Pós stricto sensu, Estagiários DGP, Residentes): Café da manhã R$ 2,00 | Almoço e Jantar R$ 4,50;
  - Grupo III (Servidores, Terceirizados e Visitantes): Café da manhã R$ 7,05 | Almoço e Jantar R$ 15,20;
  - Grupo IV (Graduação Cotas Escola Pública - Exceto Baixa Renda): Café da manhã R$ 1,50 | Almoço e Jantar R$ 2,50;
- Usuários pagantes (Grupos II, III e IV) precisam ter saldo igual ou superior ao valor da tarifa correspondente ao turno.
- O débito no saldo e o registro do acesso ocorrem apenas no momento do giro físico da catraca.
- Caso ocorra timeout (5 segundos) sem giro após a liberação, a catraca volta a bloquear e nenhum valor é debitado.
- Leituras duplicadas do cartão enquanto a catraca aguarda o giro são desconsideradas para evitar cobrança em duplicidade.

### Issue Cadastro de Usuário

- O estudante se cadastra informando matrícula, nome completo e senha (com confirmação).
- Todos os campos são obrigatórios; se algum estiver vazio, a conta não é criada.
- A senha e a confirmação de senha devem ser iguais.
- Não pode haver duas contas com a mesma matrícula; se a matrícula já estiver cadastrada, a conta não é criada.
- Quando o cadastro é concluído, a conta é criada e uma mensagem de confirmação é exibida.

### Issue Autenticação de funcionário

- O funcionário se autentica no aplicativo informando a matrícula SIAPE/nome e a senha.
- A matrícula SIAPE/nome e a senha são obrigatórios; se algum estiver vazio, o login não é realizado e o sistema informa qual campo é obrigatório.
- Se o identificador não estiver cadastrado ou a senha estiver incorreta, o login é recusado com a mensagem de credenciais inválidas.
- Após o login, o fiscal é direcionado à tela "Configuração de Ponto de Acesso", onde aparecem seu nome e sua matrícula como funcionário autenticado.
- A sessão autenticada dá acesso às telas "Configuração de Ponto", "Terminal de Validação" e "Histórico Local".
- O fiscal pode alternar a visibilidade da senha durante o preenchimento (exibida em texto ou oculta).
- Ao fazer logout, a sessão é encerrada e o fiscal retorna à tela "Autenticação do Operador".

### Issue Recarga e Saldo

- O estudante precisa estar logado para adicionar créditos à conta.
- A recarga pode ser feita por PIX (geração de QR Code no valor desejado) ou por cartão de crédito.
- O saldo só é atualizado após a confirmação do pagamento (PIX pago ou cartão aprovado), somando o valor da recarga ao saldo atual.
- Após uma recarga bem-sucedida, uma mensagem de sucesso é exibida.
- Se os dados do cartão forem inválidos, a recarga não é realizada, uma mensagem de erro é exibida e o saldo permanece inalterado.

### Issue Exportação em PDF do Histórico do Estudante

- O estudante deve estar autenticado no sistema para exportar seu histórico em PDF.
- A exportação é gerada automaticamente com base nas movimentações do mês atual vigente no momento da solicitação (não há seleção manual de período/mês nem exportação anual).
- O relatório em PDF gerado para download apresenta os dados do discente, saldo atual e o extrato consolidado de movimentações (refeições e recargas) estritamente do mês atual.
- Movimentações de meses anteriores são automaticamente desconsideradas na geração do documento e no cálculo dos totais do período.
- Se o estudante não possuir nenhuma movimentação registrada no mês atual, o sistema não deve efetuar o download e deve exibir uma mensagem informativa.

### Issue Histórico local da catraca

- A opção “Histórico Local” exibe os registros da catraca selecionada.
- Cada registro apresenta horário, matrícula do discente, modo de validação, tarifa e status da catraca.
- Ao trocar de catraca, o histórico é atualizado e exibe apenas os registros da nova seleção.
- Tentativas negadas aparecem no histórico com status “bloqueado” e o motivo da negativa.
- Tentativas negadas por saldo insuficiente não debitam nenhum valor do discente.
- É possível filtrar o histórico por turno e por status.

### Issue Visualizar Cardápio da Refeição Atual

- O estudante deve poder visualizar o cardápio da refeição que está sendo servida no momento.
- O cardápio deve apresentar três opções: padrão, ovolactovegetariana e vegetariano estrito.
- Cada opção de cardápio deve apresentar prato principal, guarnição, salada, sobremesa e bebida.
- A seção de cardápio deve apresenta o nome do restaurante e seu horário de funcionamento.
- Caso não exista cardápio cadastrado para a refeição atual, a seção deve apresentar uma mensagem informando sua indisponibilidade.


### Issue Histórico global de acessos do campus

- Apenas administradores podem visualizar o histórico global de acessos do campus.
- O histórico exibe os acessos de todos os restaurantes e de todas as catracas do campus.
- Cada acesso apresenta horário, matrícula do estudante, tarifa e status da catraca.
- O histórico apresenta o total de acessos e a arrecadação bruta do campus.
- Acessos bloqueados aparecem com tarifa "R$ 0,00" e com o motivo do bloqueio visível .
- É possível filtrar o histórico por restaurante e por catraca específica.
- Ao filtrar por restaurante, apenas as catracas desse restaurante ficam disponíveis como opção de filtro por catraca.
- É possível agrupar os dados por restaurante: cada linha exibe acessos, pontualidade e arrecadação bruta, junto com o total consolidado de todos os restaurantes.
- É possível agrupar os dados por catraca: cada linha exibe passagens e total debitado.
- Caso não existam acessos para os filtros selecionados, nenhum acesso é exibido e o sistema informa que não há acessos para os filtros selecionados.
- Fiscais não podem visualizar o histórico global: eles veem apenas o histórico local da própria catraca.

### Issue Extrato de Recargas e Histórico de Refeições

- O estudante deve estar autenticado no sistema para visualizar seu extrato e seu histórico.
- O estudante visualiza apenas as próprias movimentações; movimentações de outros estudantes nunca são exibidas.
- O extrato de recargas lista as recargas realizadas, e cada recarga apresenta data, valor e forma de pagamento.
- O extrato de recargas apresenta o total recarregado no período.
- O histórico de refeições lista as refeições realizadas, e cada refeição apresenta data, restaurante e valor debitado.
- O histórico de refeições apresenta o total gasto no período.
- A opção "Meus gastos" reúne o extrato e o histórico em um único painel, com as abas "Recargas" e "Refeições".
- É possível filtrar as movimentações por período, e o total considera apenas o período filtrado.
- Ao selecionar uma recarga da lista, o estudante visualiza seus detalhes: data, valor, forma de pagamento e status.
- Caso o estudante não possua refeições registradas no período, o sistema exibe uma mensagem informando que não há refeições no período e o total gasto é R$ 0,00.

### Padrão de commits

O grupo utiliza o padrão **Conventional Commits**, no formato `tipo: descrição curta no imperativo`.

### Política de branching

- A branch `main` do fork do grupo não recebe commits diretos.
- Existe uma branch por sprint, que reúne o trabalho de todos os integrantes.
- Cada integrante desenvolve em sua própria branch de feature ou fix, criada a partir da branch da sprint, com nome no formato `feat-nome-da-funcionalidade` ou `fix-nome-do-problema` (ex.: `feat-gestao_restaurante_catraca`).
- O trabalho de cada branch entra na branch da sprint apenas por Pull Request.
- Ao finalizar as tarefas da sprint, o grupo gera uma tag de Release e abre um Pull Request da branch da sprint para a `main` do repositório principal.

### Política de revisão

- Todo Pull Request para a branch da sprint pode ser revisado por qualquer integrante.
- O revisor confere se os commits seguem o padrão, se os cenários e o código correspondem às regras de negócio da wiki e se não há conflitos.
- O merge só é feito depois da aprovação do revisor.


## Funcionalidades e Responsáveis

| Funcionalidade                              | Responsável                     | Pontos |
| ------------------------------------------- | ------------------------------- | ------ |
| Gestão de Restaurantes e Catracas           | João Pedro Rabelo do Nascimento | 3      |
| Histórico local da catraca                  | João Pedro Rabelo do Nascimento | 3      |
| Validação de Entrada na Catraca             | Arthur Santos Almeida           | 5      |
| Exportação em PDF do Histórico do Estudante | Arthur Santos Almeida           | 3      |
| Autenticação do funcionário                 | Kamily Silva Andrade Crispim    | 3      |
| Histórico global de acessos do campus       | Kamily silva Andrade Crispim    | 3      |
| Recarga e saldo                             | Maria Luiza Macedo Bezerra      | 5      |
| Extrato e Histórico                         | Maria Luiza Macedo Bezerra      | 3      |
| Visualizar cardápio da refeição atual       | Ana Sarah Nagata                | 1      |
| Cadastro de usuário                         | Ana Sarah Nagata                | 3      |
