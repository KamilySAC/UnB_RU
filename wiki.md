# Wiki do Projeto UnB-RU

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

## Funcionalidades e Responsáveis (Sprint 1 e Sprint 2)

| Funcionalidade                              | Responsável                     | Pontos | Status Sprint 2 |
| ------------------------------------------- | ------------------------------- | ------ | --------------- |
| Gestão de Restaurantes e Catracas           | João Pedro Rabelo do Nascimento | 3      | Concluído ✅    |
| Histórico local da catraca                  | João Pedro Rabelo do Nascimento | 3      | Concluído ✅    |
| Validação de Entrada na Catraca             | Arthur Santos Almeida           | 5      | Concluído ✅    |
| Exportação em PDF do Histórico do Estudante | Arthur Santos Almeida           | 3      | Concluído ✅    |
| Autenticação do funcionário                 | Kamily Silva Andrade Crispim    | 3      | Concluído ✅    |
| Histórico global de acessos do campus       | Kamily Silva Andrade Crispim    | 3      | Concluído ✅    |
| Recarga e saldo                             | Maria Luiza Macedo Bezerra      | 5      | Concluído ✅    |
| Extrato e Histórico                         | Maria Luiza Macedo Bezerra      | 3      | Concluído ✅    |
| Visualizar cardápio da refeição atual       | Ana Sarah Nagata                | 1      | Concluído ✅    |
| Cadastro de usuário                         | Ana Sarah Nagata                | 3      | Concluído ✅    |

---

# Documentação da Sprint 2

## 1. Visão Geral

Na **Sprint 2**, o objetivo principal é a implementação do código de produção das funcionalidades especificadas em BDD durante a Sprint 1, acompanhadas da respectiva suíte de testes unitários com **RSpec** e validação contínua de comportamento com **Cucumber**.

---

## 2. Detalhamento das Features Entregues

### 2.1. Validação de Entrada na Catraca do RU

- **Responsável:** Arthur Santos Almeida (Matrícula: 242009990)
- **Pontuação:** 5 pontos
- **Branch:** `feat/validacao_entrada` (Merged em `Sprint_2` via PR #9)
- **Status:** Concluído e testado (100% de cobertura)

#### Regras de Negócio e Comportamentos Implementados:

1. **Identificação do Estudante:** Leitura e decodificação do identificador/QR-Code gerado pelo aplicativo institucional, validando existência na base de dados e vínculo ativo.
2. **Cálculo Dinâmico de Tarifas:** Aplicação das tarifas vigentes de acordo com o turno da refeição e perfil socioeconômico:
   - _Grupo I (Isenção Integral):_ Tarifa R$ 0,00 para qualquer turno, liberando passagem sem exigência de saldo.
   - _Grupo II (Graduação / Pós):_ Café da manhã: R$ 2,00 | Almoço e Jantar: R$ 4,50.
   - _Grupo III (Servidores / Terceirizados / Visitantes):_ Café da manhã: R$ 7,05 | Almoço e Jantar: R$ 15,20.
   - _Grupo IV (Cotas Escola Pública):_ Café da manhã: R$ 1,50 | Almoço e Jantar: R$ 2,50.
3. **Validação de Saldo Suficiente:** Verificação prévia de saldo para grupos pagantes. Caso o saldo seja inferior ao valor do turno, a catraca permanece bloqueada e o visor exibe _"Saldo insuficiente"_.
4. **Tratamento de Usuário Inexistente:** Caso a matrícula lida não conste no cadastro, a catraca permanece bloqueada e o visor exibe _"Usuário não encontrado"_.
5. **Comando de Liberação e Timeout de 5 Segundos:** A catraca é colocada em estado de pré-liberação (`liberada`). Se o sensor de giro não for acionado dentro da janela de 5 segundos, a catraca volta ao estado `bloqueada` e nenhum valor é debitado do estudante.
6. **Débito no Giro Físico:** O débito financeiro no saldo do estudante e a confirmação do registro de acesso acontecem exclusivamente no momento em que o giro físico da catraca é registrado.
7. **Política Anti-Passback (Prevenção de Duplo Acesso):** Bloqueio automático de tentativas de entrada repetidas no mesmo turno e data para o mesmo discente, exibindo _"Refeição já utilizada neste turno"_ sem cobrança duplicada.

#### Arquitetura e Arquivos da Feature:

- **Models:**
  - `app/models/estudante.rb`: métodos de validação, cálculo de tarifas e manipulação de saldo.
  - `app/models/acesso_catraca.rb`: controle de status (`liberada`/`bloqueada`), timeout, anti-passback e confirmação de giro.
- **Migração:** `db/migrate/20260601000000_create_validacao_entrada_tables.rb` (criação das tabelas `estudantes` e `acessos_catraca`).
- **Testes Unitários (RSpec):**
  - `spec/models/estudante_spec.rb`: 11 exemplos cobrindo regras tarifárias e validação de saldo.
  - `spec/models/acesso_catraca_spec.rb`: 9 exemplos cobrindo leitura, liberação, recusa, timeout e anti-passback.
- **Testes de Comportamento (BDD Cucumber):**
  - `features/validacao_entrada.feature`: 22 cenários cobrindo caminhos felizes e tristes.
  - `features/step_definitions/validacao_entrada_steps.rb`: 140 passos automatizados com 100% de aprovação.

---

### 2.2. Exportação em PDF do Histórico do Estudante

- **Responsável:** Arthur Santos Almeida (Matrícula: 242009990)
- **Pontuação:** 3 pontos
- **Branch:** `feat/exportar_historico_pdf` (Merged em `Sprint_2` via PR #10)
- **Status:** Concluído e testado (100% de cobertura)

#### Regras de Negócio e Comportamentos Implementados:

1. **Geração em Formato PDF:** Produção de documento formal estruturado no formato A4 através da gem `prawn` (~> 2.4).
2. **Restrição Temporal ao Mês Atual:** Filtro estrito do período de apuração (`beginning_of_month..end_of_month`). Movimentações de meses anteriores são sumariamente desconsideradas na geração e no cálculo dos totais consolidados.
3. **Consolidação Financeira:** Cálculo automático e formatação monetária (padrão BRL) do total recarregado e do total consumido no mês de referência.
4. **Detalhamento das Operações:**
   - Dados cadastrais do discente: nome, matrícula, grupo tarifário e saldo atual.
   - Extrato de recargas do mês com data, modalidade de pagamento (PIX / Cartão), valor e status da transação.
   - Histórico de refeições do mês com data, restaurante de atendimento e valor debitado.
5. **Tratamento de Ausência de Movimentações (Caminho Triste):** Quando o estudante não possui histórico nem recargas no mês corrente, o serviço aborta a emissão do PDF e a aplicação exibe a mensagem informativa: _"Não há movimentações registradas no mês atual"_, impedindo downloads de arquivos vazios.

#### Arquitetura e Arquivos da Feature:

- **Service:** `app/services/gerador_historico_pdf.rb` (lógica de consulta, cálculo, composição visual e renderização do PDF).
- **Controller e Rotas:** `app/controllers/historicos_controller.rb` e rota `get "historico/exportar_pdf"`.
- **Models:**
  - `app/models/recarga.rb`: persistência das operações de recarga.
  - `app/models/refeicao.rb`: persistência das refeições consumidas pelo estudante.
  - Associação `has_many :recargas` e `has_many :refeicoes` no modelo `Estudante`.
- **Migração:** `db/migrate/20260601000001_create_movimentacoes_tables.rb`.
- **Testes Unitários (RSpec):**
  - `spec/services/gerador_historico_pdf_spec.rb`: 5 exemplos cobrindo filtro de datas, totais, descarte de meses anteriores e bloqueio de extrato vazio.
- **Testes de Comportamento (BDD Cucumber):**
  - `features/exportar_historico_pdf.feature`: 3 cenários (caminho feliz com movimentações, caminho feliz ignorando meses anteriores e caminho triste sem movimentações).
  - `features/step_definitions/exportar_historico_pdf_steps.rb`: 16 passos automatizados com 100% de aprovação.

### 2.3. Gestão de Restaurantes e Catracas

- **Responsável:** João Pedro Rabelo do Nascimento (Matrícula: 241036160)
- **Pontuação:** 3 pontos
- **Status:** Implementado; cenários Cucumber e testes de requisição RSpec preparados.

#### Regras de Negócio e Comportamentos Implementados:

1. **Listagem de Restaurantes:** Exibe restaurantes cadastrados, seus dados e as catracas associadas.
2. **Cadastro e Edição de Restaurantes:** Permite cadastrar e alterar os dados do restaurante. O nome é obrigatório e não pode se repetir.
3. **Cadastro de Catracas:** Cada catraca é associada a um restaurante existente e tem código, nome, piso e estado.
4. **Validação do Piso:** O piso da catraca deve ser positivo e não pode ultrapassar o total de pisos do restaurante.
5. **Edição de Catracas:** Permite alterar o estado da catraca entre online e offline.
6. **Restaurante Inexistente:** A aplicação retorna “não encontrado” ao tentar abrir o cadastro de catraca para um restaurante inexistente.
7. **Autorização por Papel:** A autenticação e a autorização de administradores e funcionários ainda não estão implementadas; portanto, a restrição por papel descrita nos requisitos não é aplicada pela aplicação.

#### Arquitetura e Arquivos da Feature:

- **Controllers e Rotas:**
  - `app/controllers/restaurantesController.rb`: listagem, cadastro, edição e remoção de restaurantes.
  - `app/controllers/catracas_controller.rb`: cadastro, edição e remoção de catracas.
  - `config/routes.rb`: rotas de restaurantes e catracas; a página inicial aponta para a listagem de restaurantes.
- **Models:**
  - `app/models/restaurante.rb`: valida nome obrigatório e exclusivo, capacidade e total de pisos.
  - `app/models/catraca.rb`: associa a catraca a um restaurante e valida código, nome e piso.
- **Views:** `app/views/restaurantes/` e `app/views/catracas/` contêm as telas e formulários de gestão.
- **Testes de Requisição (RSpec):**
  - `spec/requests/gestao_restaurantes_spec.rb`: 8 exemplos definidos para listagem, cadastro, validações, edição, associação de catracas e restaurante inexistente.
- **Testes de Comportamento (BDD Cucumber):**
  - `features/gerenciar_restaurantes.feature`: 8 cenários para cadastro, edição e validações de restaurantes e catracas.
  - `features/step_definitions/gerenciar_restaurantes_steps.rb`: steps que interagem com as telas usando o navegador. O cenário de bloqueio de funcionário permanece pendente enquanto não houver autorização por papel.

### 2.4. Histórico Local da Catraca

- **Responsável:** João Pedro Rabelo do Nascimento (Matrícula: 241036160)
- **Pontuação:** 3 pontos
- **Status:** Implementado; cenários Cucumber e testes de requisição RSpec preparados.

#### Regras de Negócio e Comportamentos Implementados:

1. **Histórico da Catraca Selecionada:** Exibe os acessos vinculados à catraca consultada, em ordem do mais recente para o mais antigo, com horário, matrícula, modo de validação, turno, tarifa, estado e motivo de bloqueio.
2. **Separação por Catraca:** Ao consultar uma catraca, os acessos de outras catracas não são exibidos.
3. **Filtros:** Permite filtrar os registros por data, turno, status do acesso e modo de validação. Um status desconhecido ou uma data inválida resulta em resposta de erro.
4. **Resumo Diário:** Mostra a quantidade de passagens liberadas e o total debitado no dia; tentativas bloqueadas não entram nesses valores.
5. **Tentativas Negadas:** Registra e mostra o status bloqueado e o motivo da negativa.
6. **Registro Manual:** Disponibiliza um formulário para registrar acessos manualmente e retorna ao histórico após o registro.

#### Arquitetura e Arquivos da Feature:

- **Controller e Rotas:**
  - `app/controllers/acessos_controller.rb`: consulta e filtra o histórico, calcula o resumo diário e registra acessos manuais.
  - `config/routes.rb`: rotas de histórico e registro de acesso aninhadas sob a catraca.
- **Models:**
  - `app/models/acesso.rb`: associa o acesso à catraca e valida os campos, tarifa e motivo obrigatório para acessos bloqueados.
  - `app/models/catraca.rb`: associa a catraca ao restaurante e aos seus acessos.
- **Views:** `app/views/acessos/index.html.erb` exibe o histórico e os filtros; `app/views/acessos/new.html.erb` contém o formulário de registro manual.
- **Testes de Requisição (RSpec):**
  - `spec/requests/acessos_spec.rb`: 7 exemplos definidos para exibição, isolamento por catraca, filtros, formulário e registro manual.
- **Testes de Comportamento (BDD Cucumber):**
  - `features/historico_catraca.feature`: 7 cenários de visualização, isolamento, troca de catraca, histórico vazio, tentativa negada e filtros por turno e status.
  - `features/step_definitions/historico_catraca_steps.rb`: steps que preparam dados fixos e exercitam o histórico pela interface do navegador.

### 2.5. Cadastro de Usuário

- **Responsável:** Ana Sarah Nagata (Matrícula: 242023176)
- **Pontuação:** 3 pontos
- **Status:** Concluído e testado

#### Regras de Negócio e Comportamentos Implementados:

1. **Dados do Cadastro:** O estudante informa matrícula, nome completo e senha (com confirmação) no formulário `/cadastro`.
2. **Campos Obrigatórios:** Se algum campo estiver vazio (ou só com espaços), a conta não é criada e é exibida a mensagem "Todos os campos devem ser preenchidos".
3. **Confirmação de Senha:** Senha e confirmação precisam ser iguais; caso contrário, "As senhas não são iguais". A senha aceita no máximo 72 bytes (limite do bcrypt).
4. **Matrícula Única:** Não existem duas contas com a mesma matrícula ("Matrícula já cadastrada"), inclusive se duas requisições simultâneas tentarem o mesmo cadastro (índice único tratado).
5. **Conta Criada:** A senha é guardada criptografada (`has_secure_password`), a sessão do estudante é iniciada e ele é levado ao dashboard com a mensagem "Cadastro realizado com sucesso! Sua conta foi criada."
6. **Compatibilidade com o Login:** O login do estudante usa a mesma matrícula e senha do cadastro.

#### Arquitetura e Arquivos da Feature:

- **Service:** `app/services/cadastro_estudante.rb` (validações e criação da conta).
- **Controller, view e rotas:** `app/controllers/estudantes_controller.rb`, `app/views/estudantes/new.html.erb` e rotas `GET/POST /cadastro`.
- **Model:** `app/models/estudante.rb` (`has_secure_password`, matrícula única).
- **Testes Unitários e de Requisição (RSpec):**
  - `spec/services/cadastro_estudante_spec.rb`
  - `spec/requests/estudante_spec.rb`
  - `spec/requests/sessions_spec.rb` (cadastro seguido de login com a mesma matrícula e senha)
- **Testes de Comportamento (BDD Cucumber):**
  - `features/cadastro_usuario.feature`: 4 cenários (1 caminho feliz e 3 caminhos tristes).
  - `features/step_definitions/cadastro_usuario_steps.rb`: passos pela tela `/cadastro`, conferindo o banco.

### 2.6. Visualizar Cardápio da Refeição Atual

- **Responsável:** Ana Sarah Nagata (Matrícula: 242023176)
- **Pontuação:** 1 ponto
- **Status:** Concluído e testado

#### Regras de Negócio e Comportamentos Implementados:

1. **Refeição Atual:** O turno em andamento é calculado pelo horário de Brasília: Café da manhã (07:00 às 09:00), Almoço (11:00 às 14:30) e Jantar (17:30 às 19:30). O início é inclusivo e o término é exclusivo.
2. **Cardápio do Dia:** O cardápio vem do arquivo `cardapio.json`, indexado por dia da semana e turno.
3. **Três Opções:** São exibidas as opções padrão, ovolactovegetariano e vegetariano estrito, cada uma com prato principal, guarnição, salada, sobremesa e bebida. No café da manhã, o complemento do pão faz o papel de prato principal e a fruta o de sobremesa; no jantar, sopa e torrada são a guarnição. Os acompanhamentos (arroz e feijão) aparecem uma vez para todas as opções.
4. **Restaurante e Horário:** A seção exibe o nome do restaurante (o primeiro cadastrado; "RU Darcy Ribeiro" se não houver) e o horário de funcionamento do turno.
5. **Indisponibilidade (Caminho Triste):** Fora do horário de funcionamento, em dia sem cardápio ou com arquivo ausente/inválido, a seção exibe "Cardápio indisponível para a refeição atual."
6. **Onde Aparece:** Na página inicial do estudante logado (dashboard), logo abaixo do saldo; a raiz `/` redireciona o estudante logado para ela.

#### Arquitetura e Arquivos da Feature:

- **Service:** `app/services/cardapio_atual.rb` (leitura do JSON, turno atual e montagem das opções).
- **Controller e View:** `app/controllers/dashboard_controller.rb` e `app/views/dashboard/_cardapio.html.erb` (renderizada em `dashboard/show`).
- **Testes Unitários e de Requisição (RSpec):**
  - `spec/services/cardapio_atual_spec.rb`: 16 exemplos (turnos, limites de horário, fuso, café, jantar e indisponibilidade).
  - `spec/requests/cardapio_spec.rb`: 5 exemplos (seção na página inicial, indisponibilidade e acesso sem login).
- **Testes de Comportamento (BDD Cucumber):**
  - `features/visualizar_cardapio.feature`: 2 cenários (caminho feliz e caminho triste).
  - `features/step_definitions/visualizar_cardapio_steps.rb`: o relógio é fixado numa segunda-feira às 12h e o `cardapio.json` é trocado por um arquivo de teste.

---

---
### 2.5. Recarga e Saldo

- **Responsável:** Maria Luiza Macedo Bezerra (Matrícula: 221010372)
- **Pontuação:** 5 pontos
- **Branch:** `feat/recarga_saldo`
- **Status:** Concluído e testado

#### Regras de Negócio e Comportamentos Implementados:

1. **Autenticação Obrigatória:** O estudante precisa estar logado para adicionar créditos à conta. Sem sessão ativa, a operação de recarga é bloqueada.
2. **Recarga via PIX:** Geração de QR Code de recarga no valor desejado (`R$ x`). O saldo só é atualizado após a confirmação do pagamento do PIX.
3. **Recarga via Cartão de Crédito:** Inserção dos dados de um cartão válido e confirmação da recarga no valor de `R$ x`. O saldo é atualizado somente após a aprovação do cartão.
4. **Atualização Condicionada do Saldo:** O saldo só é somado ao valor da recarga após a confirmação do pagamento (PIX pago ou cartão aprovado). O saldo anterior permanece inalterado até a confirmação.
5. **Mensagem de Sucesso:** Após uma recarga bem-sucedida (PIX ou cartão), uma mensagem de sucesso é exibida ao estudante.
6. **Tratamento de Cartão Inválido (Caminho Triste):** Se os dados do cartão forem inválidos, a recarga não é realizada, uma mensagem de erro é exibida e o saldo permanece inalterado.

#### Cenários BDD (`creditos.feature`):

| Cenário | Descrição |
| --- | --- |
| Adicionar créditos com sucesso via PIX | Escolha do PIX, geração do QR Code, pagamento e atualização do saldo para `+R$ x` com mensagem de sucesso |
| Adicionar créditos com sucesso via cartão de crédito | Inserção de cartão válido, confirmação da recarga e atualização do saldo para `+R$ x` com mensagem de sucesso |
| Tentar adicionar créditos via cartão de crédito com dados inválidos | Inserção de dados inválidos, tentativa de confirmação, exibição de mensagem de erro e saldo não alterado |

#### Arquitetura e Arquivos da Feature:

- **Models:**
  - `app/models/recarga.rb`: persistência das operações de recarga (valor, forma de pagamento, status).
  - `app/models/estudante.rb`: manipulação e atualização do saldo do estudante.
- **Controller e Rotas:** controller responsável pelas operações de recarga e rotas associadas ao fluxo de adição de créditos.
- **Migração:** tabela de recargas vinculada ao estudante.
- **Testes Unitários (RSpec):**
  - `spec/models/recarga_spec.rb`: exemplos cobrindo validação de valor, forma de pagamento e atualização condicionada do saldo.
- **Testes de Comportamento (BDD Cucumber):**
  - `features/creditos.feature`: 3 cenários (PIX com sucesso, cartão com sucesso e cartão inválido).
  - `features/step_definitions/creditos_steps.rb`: steps automatizados para os fluxos de recarga.

---

### 2.6. Extrato e Histórico

- **Responsável:** Maria Luiza Macedo Bezerra (Matrícula: 221010372)
- **Pontuação:** 3 pontos
- **Branch:** `feat/extrato_historico`
- **Status:** Concluído e testado

#### Regras de Negócio e Comportamentos Implementados:

1. **Autenticação Obrigatória:** O estudante deve estar autenticado para visualizar seu extrato e seu histórico.
2. **Isolamento por Estudante:** O estudante visualiza apenas as próprias movimentações; movimentações de outros estudantes nunca são exibidas.
3. **Extrato de Recargas:** Lista as recargas realizadas, cada uma com data, valor e forma de pagamento, além do total recarregado no período.
4. **Histórico de Refeições:** Lista as refeições realizadas, cada uma com data, restaurante e valor debitado, além do total gasto no período.
5. **Painel "Meus gastos":** Reúne o extrato e o histórico em um único painel, com as abas "Recargas" e "Refeições".
6. **Filtro por Período:** É possível filtrar as movimentações por período, e o total considera apenas o período filtrado.
7. **Detalhes de uma Recarga:** Ao selecionar uma recarga da lista, o estudante visualiza seus detalhes: data, valor, forma de pagamento e status.
8. **Histórico Vazio (Caminho Triste):** Caso o estudante não possua refeições registradas no período, o sistema exibe uma mensagem informando que não há refeições no período e o total gasto é `R$ 0,00`.

#### Cenários BDD (`extrato_historico.feature`):

| Cenário | Descrição |
| --- | --- |
| Visualizar extrato de recargas com sucesso | Lista de recargas com data, valor e forma de pagamento, e total recarregado no período |
| Visualizar histórico de refeições com sucesso | Lista de refeições com data, restaurante e valor debitado, e total gasto no período |
| Visualizar extrato e histórico em um único painel | Abas "Recargas" e "Refeições" na opção "Meus gastos" |
| Filtrar movimentações por período | Filtro de `01/10/2026` a `31/10/2026`, exibindo apenas refeições do período e total filtrado |
| Visualizar detalhes de uma recarga | Detalhes com data, valor, forma de pagamento e status |
| Visualizar histórico de refeições vazio | Mensagem informando ausência de refeições e total gasto `R$ 0,00` |
| Não visualizar movimentações de outro estudante | Exibição apenas das próprias recargas, sem recargas de outros estudantes |

#### Arquitetura e Arquivos da Feature:

- **Models:**
  - `app/models/recarga.rb`: persistência das recargas do estudante.
  - `app/models/refeicao.rb`: persistência das refeições consumidas pelo estudante.
  - Associação `has_many :recargas` e `has_many :refeicoes` no modelo `Estudante`.
- **Controller e Rotas:** controller responsável pela exibição do extrato, histórico, painel "Meus gastos", filtros por período e detalhes de recarga.
- **Testes Unitários (RSpec):**
  - `spec/models/refeicao_spec.rb`: exemplos cobrindo validação dos dados da refeição.
  - `spec/requests/historicos_spec.rb`: exemplos cobrindo exibição do extrato, histórico, isolamento por estudante, filtros por período e histórico vazio.
- **Testes de Comportamento (BDD Cucumber):**
  - `features/extrato_historico.feature`: 7 cenários cobrindo extrato, histórico, painel único, filtro por período, detalhes de recarga, histórico vazio e isolamento por estudante.
  - `features/step_definitions/extrato_historico_steps.rb`: steps automatizados para os fluxos de visualização.



---

#### Resumo da Suíte de Testes — Maria Luiza Macedo Bezerra

| Tipo de Teste | Arquivos Avaliados | Cobertura |
| --- | --- | --- |
| **RSpec** | `recarga_spec.rb`, `refeicao_spec.rb`, `historicos_spec.rb` | Recarga e Saldo + Extrato e Histórico |
| **Cucumber** | `creditos.feature`, `extrato_historico.feature` | 10 cenários (3 de recarga + 7 de extrato/histórico) |

---

### 2.9. Autenticação do Funcionário

- **Responsável:** Kamily Silva Andrade Crispim (Matrícula: 242009945)
- **Pontuação:** 3 pontos
- **Branch:** `feat/autenticacao_funcionario` (Pull Request para `Sprint_2`)
- **Status:** Concluído e testado

#### Regras de Negócio e Comportamentos Implementados:

1. **Entrar no sistema:** O funcionário abre a tela "Autenticação do Operador" (`/funcionario/login`) e informa a matrícula SIAPE (7 números) ou o nome de usuário, e a senha. Espaços sobrando não atrapalham, e o usuário pode ser escrito com letra maiúscula ou minúscula.
2. **Campos obrigatórios:** Se faltar a matrícula/usuário ou a senha, o login não acontece e o sistema avisa qual campo está faltando ("A matrícula ou usuário é obrigatório." ou "A senha é obrigatória.").
3. **Dados errados:** Se a matrícula/usuário não existir ou a senha estiver errada, aparece sempre a mesma mensagem: "Credenciais inválidas.". Assim, ninguém descobre se um cadastro existe.
4. **Senha segura:** A senha tem no mínimo 8 caracteres e é guardada de forma criptografada (embaralhada), nunca como texto normal.
5. **Depois do login:** O fiscal vai para a tela "Configuração de Ponto de Acesso", que mostra o nome e a matrícula dele. A cada login a sessão começa do zero, por segurança. Também há um limite de 10 tentativas a cada 3 minutos, para impedir quem tenta adivinhar senhas.
6. **Telas que exigem login:** "Configuração de Ponto", "Terminal de Validação" e "Histórico Local" só abrem para quem está logado. Quem não entrou é levado ao login com o aviso "Faça login para continuar.". O "Histórico Local" mostra a lista de catracas, com um link para o histórico de cada uma.
7. **Mostrar a senha:** Um botão ao lado do campo mostra ou esconde a senha enquanto ela é digitada.
8. **Sair:** O botão "Sair" encerra a sessão e volta para o login, com a mensagem "Sessão encerrada.".
9. **Tipos de funcionário:** Cada funcionário é "fiscal" ou "administrador". O administrador entra pelo mesmo login e também vê o histórico global. Quem não é administrador e tenta abrir uma tela só do administrador é levado ao "Histórico Local", com o aviso "Você não tem permissão para acessar esta tela.".
10. **Ainda falta:** A regra "só administrador" ainda não foi aplicada na gestão de restaurantes e catracas (feature 2.3).

#### Arquitetura e Arquivos da Feature:

- **Cadastro do funcionário (model):** `app/models/funcionario.rb` guarda nome, matrícula SIAPE (única), usuário (opcional e único), senha e tipo (fiscal ou administrador). Também confere se a matrícula/usuário e a senha estão certos.
- **Banco de dados:** `db/migrate/20261114000000_create_funcionarios.rb` cria a tabela de funcionários.
- **Controle de login:** `app/controllers/concerns/autenticacao.rb` reúne funções usadas pelo sistema todo: saber quem está logado, exigir login e exigir administrador.
- **Controllers e rotas:**
  - `app/controllers/funcionario_sessions_controller.rb`: entrar e sair (`/funcionario/login` e `/funcionario/logout`).
  - `app/controllers/painel_controller.rb`: telas liberadas depois do login (`/ponto-de-acesso`, `/terminal-de-validacao` e `/historico-local`).
- **Telas (views):** `app/views/funcionario_sessions/new.html.erb` (tela de login), `app/views/painel/` (telas depois do login) e o menu do funcionário no layout.
- **JavaScript:** `app/javascript/controllers/senha_controller.js` faz o botão de mostrar e esconder a senha.
- **Dados de demonstração:** `db/seeds.rb` cria um fiscal e um administrador de teste, só no ambiente de desenvolvimento.
- **Testes de código (RSpec):**
  - `spec/models/funcionario_spec.rb`: 11 exemplos (regras do cadastro, senha criptografada e conferência de matrícula/usuário e senha).
  - `spec/requests/funcionario_sessions_spec.rb`: 7 exemplos (tela de login, login certo, dados errados, campos vazios e sair).
  - `spec/requests/painel_spec.rb`: 7 exemplos (telas com e sem login e lista de catracas do Histórico Local).
- **Testes de comportamento (Cucumber):**
  - `features/autenticar_funcionario.feature`: 10 cenários (6 de caminho feliz e 4 de caminho triste). O cenário do botão de mostrar a senha usa o navegador Chrome, sem abrir janela.
  - `features/step_definitions/autenticacao_steps.rb`: 26 passos que usam a tela de login de verdade.

---

### 2.10. Histórico Global de Acessos do Campus

- **Responsável:** Kamily Silva Andrade Crispim (Matrícula: 242009945)
- **Pontuação:** 3 pontos
- **Branch:** `feat/relatorio_global_acesso` (Pull Request para `Sprint_2`)
- **Status:** Concluído e testado

#### Regras de Negócio e Comportamentos Implementados:

1. **Só para administrador:** Apenas o administrador logado vê o histórico global. Quem não entrou é levado ao login. O fiscal é levado ao "Histórico Local", com um aviso. O link "Histórico Global" no menu só aparece para o administrador.
2. **Lista completa:** Mostra todos os acessos de todos os restaurantes e catracas do campus, dos mais novos para os mais antigos. Cada acesso mostra horário, restaurante, catraca, matrícula, tarifa, status do acesso, status da catraca e motivo do bloqueio (quando houver).
3. **Totais:** Mostra o total de acessos (contando também os bloqueados) e a arrecadação bruta (soma apenas dos acessos liberados). Os totais mudam conforme os filtros escolhidos.
4. **Acessos bloqueados:** Aparecem com tarifa "R$ 0,00" e com o motivo do bloqueio, porque nada é cobrado nesses casos.
5. **Filtros:** Dá para filtrar por restaurante e por catraca. Ao escolher um restaurante, só as catracas dele aparecem como opção. Se chegar uma catraca que não é daquele restaurante, ela é ignorada. Se o restaurante ou a catraca não existir, o sistema recusa o pedido (erro 400, "pedido inválido").
6. **Agrupar por restaurante:** Mostra uma linha para cada restaurante (mesmo os sem acessos), com acessos, pontualidade e arrecadação bruta. No fim, uma linha "Total consolidado" soma todos. A pontualidade é a porcentagem de acessos que **não** foram bloqueados por "Janela Expirada". Quando não há acessos, aparece "—".
7. **Agrupar por catraca:** Mostra uma linha para cada catraca ("Restaurante - Catraca"), com as passagens (acessos liberados) e o total debitado.
8. **Sem resultado:** Se nenhum acesso combinar com os filtros, nenhum acesso é mostrado e aparece a mensagem "Não há acessos para os filtros selecionados.".
9. **Fiscal:** O fiscal não vê o histórico global, só o histórico local.

#### Arquitetura e Arquivos da Feature:

- **Cálculos (service):** `app/services/historico_global.rb` aplica os filtros e faz as contas dos totais e dos agrupamentos.
- **Controller e rota:** `app/controllers/historico_global_controller.rb` recebe o pedido `GET /historico-global` (com restaurante, catraca e agrupamento) e confere se quem pediu é administrador.
- **Formatação (helper):** `app/helpers/historico_global_helper.rb` mostra os valores em reais (R$ 1.234,50) e a pontualidade em porcentagem, e faz o acesso bloqueado aparecer com tarifa zerada.
- **Tela (view):** `app/views/historico_global/index.html.erb` tem os filtros, os totais e a lista (ou a tabela agrupada).
- **Dados usados:** `Restaurante`, `Catraca` e `Acesso` (features 2.3 e 2.4) e o login da feature 2.9.
- **Testes de código (RSpec):**
  - `spec/services/historico_global_spec.rb`: 15 exemplos (filtros, totais, agrupamentos, restaurante sem acessos e pontualidade).
  - `spec/requests/historico_global_spec.rb`: 15 exemplos (quem pode ver, lista, totais, bloqueados, filtros, agrupamentos e pedido inválido).
- **Testes de comportamento (Cucumber):**
  - `features/acesso_global.feature`: 10 cenários (7 de caminho feliz e 3 de caminho triste).
  - `features/step_definitions/acesso_global_steps.rb`: 32 passos que usam a tela do histórico global.

## 3. Resumo da Suíte de Testes (Arthur Santos Almeida)

| Tipo de Teste | Arquivos Avaliados                                                                                                                          | Total Executado              | Falhas / Erros     |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | ------------------ |
| **RSpec**     | `estudante_spec.rb`, `acesso_catraca_spec.rb`, `gerador_historico_pdf_spec.rb`, `recarga_spec.rb`, `refeicao_spec.rb`, `historicos_spec.rb` | **34 exemplos**              | **0** (100% verde) |
| **Cucumber**  | `validacao_entrada.feature`, `exportar_historico_pdf.feature`                                                                               | **25 cenários / 156 passos** | **0** (100% verde) |

### Como reproduzir os testes localmente:

```bash
# Executar todos os testes unitários e de requisição RSpec
bundle exec rspec

# Executar os testes BDD Cucumber de validação de catraca e exportação PDF
bundle exec cucumber features/validacao_entrada.feature features/exportar_historico_pdf.feature
```

### 3.1. Suítes de Testes — Gestão e Histórico Local

| Funcionalidade                    | RSpec                                                    | Cucumber                                               |
| --------------------------------- | -------------------------------------------------------- | ------------------------------------------------------ |
| Gestão de restaurantes e catracas | `spec/requests/gestao_restaurantes_spec.rb` — 8 exemplos | `features/gerenciar_restaurantes.feature` — 8 cenários |
| Histórico local da catraca        | `spec/requests/acessos_spec.rb` — 7 exemplos             | `features/historico_catraca.feature` — 7 cenários      |

Para executar somente essas suítes:

```bash

bundle exec rspec spec/requests/gestao_restaurantes_spec.rb spec/requests/acessos_spec.rb

bundle exec cucumber features/gerenciar_restaurantes.feature features/historico_catraca.feature
```

### 3.2. Suítes de Testes — Cadastro e Cardápio (Ana Sarah Nagata)

| Funcionalidade | RSpec                                                                                        | Cucumber                                            |
| -------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Cadastro       | `spec/services/cadastro_estudante_spec.rb` e `spec/requests/estudante_spec.rb` — 27 exemplos | `features/cadastro_usuario.feature` — 4 cenários    |
| Cardápio       | `spec/services/cardapio_atual_spec.rb` e `spec/requests/cardapio_spec.rb` — 21 exemplos      | `features/visualizar_cardapio.feature` — 2 cenários |

Para executar somente essas suítes:

```bash
bundle exec rspec spec/services/cadastro_estudante_spec.rb spec/requests/estudante_spec.rb spec/requests/sessions_spec.rb spec/services/cardapio_atual_spec.rb spec/requests/cardapio_spec.rb

bundle exec cucumber features/cadastro_usuario.feature features/visualizar_cardapio.feature
```

### 3.3. Suítes de Testes — Autenticação e Histórico Global (Kamily Silva Andrade Crispim)

| Funcionalidade              | RSpec                                                                                                                          | Cucumber                                                |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| Autenticação do funcionário | `spec/models/funcionario_spec.rb`, `spec/requests/funcionario_sessions_spec.rb` e `spec/requests/painel_spec.rb` — 25 exemplos | `features/autenticar_funcionario.feature` — 10 cenários |
| Histórico global de acessos | `spec/services/historico_global_spec.rb` e `spec/requests/historico_global_spec.rb` — 30 exemplos                              | `features/acesso_global.feature` — 10 cenários          |

Para executar somente essas suítes:

```bash
bundle exec rspec spec/models/funcionario_spec.rb spec/requests/funcionario_sessions_spec.rb spec/requests/painel_spec.rb spec/services/historico_global_spec.rb spec/requests/historico_global_spec.rb

bundle exec cucumber features/autenticar_funcionario.feature features/acesso_global.feature
```

O cenário "Alternar a visibilidade da senha" precisa do Google Chrome instalado. Se você não tiver o Chrome, rode o Cucumber com `--tags "not @javascript"` para pular esse cenário.

---

## 4. Declaração de Uso de Inteligência Artificial

Em conformidade com as diretrizes da disciplina de Engenharia de Software:

- **Ferramenta Utilizada:** Antigravity / Gemini.
- **Partes do Projeto:** Apoio na estruturação inicial dos step definitions em Cucumber (`validacao_entrada_steps.rb` e `exportar_historico_pdf_steps.rb`), desenho da classe de serviço para geração de PDF com a gem Prawn (`gerador_historico_pdf.rb`) e montagem dos testes unitários em RSpec.
- **Estratégia Adotada:** Pair programming assistido por IA com foco em metodologia TDD/BDD. Cada método, consulta ao banco e validação foi revisado, ajustado e executado iterativamente no terminal pelo desenvolvedor Arthur Santos Almeida, assegurando total domínio sobre a arquitetura do código e capacidade de explicabilidade técnica de cada componente.

### Declaração de Uso de IA — João Pedro Rabelo do Nascimento

- **Ferramenta Utilizada:** Copilot e Claude.
- **Partes do Projeto:** Apoio na elaboração e ajuste dos steps Cucumber de gestão de restaurantes e catracas e do histórico local; configuração do workflow de CI para executar RuboCop, RSpec e Cucumber; e configuração da rota inicial para exibir a listagem de restaurantes, e também utilizada para gerar um front-end funcional, sendo necessário apenas alguns ajustes manuais para encaixar com a ideia do sistema.
- **Uso da ferramenta:** A IA foi utilizada como apoio para explicar o código, sugerir e aplicar alterações. A validação final das mudanças e a compreensão do código permaneceram sob minha responsabilidade.


### Declaração de Uso de IA — Ana Sarah Nagata

- **Ferramenta Utilizada:** Claude e ChatGPT.
- **Partes do Projeto:** Apoio na análise da incompatibilidade entre o cadastro e o login por email, na implementação do cardápio da refeição e no esqueleto do cadastro de usuário.
- **Uso da ferramenta:** A IA foi usada como apoio para sugerir e escrever código e testes; melhoramento de código e detectar bugs.

### Declaração de Uso de IA — Kamily Silva Andrade Crispim

- **Ferramenta Utilizada:** Claude.
- **Partes do Projeto:** Apoio na autenticação do funcionário e correção de erro na visibilidade da senha; Na resolução dos conflitos do merge; na correção de erros de configuração do ambiente no Windows; e na escrita do texto da wiki das minhas duas features.
- **Uso da ferramenta:** A IA foi usada como apoio para melhorar codigo e para explicar os erros que apareciam.