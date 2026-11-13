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
| Autenticação do funcionário                 | Kamily Silva Andrade Crispim    | 3      | Em andamento    |
| Histórico global de acessos do campus       | Kamily Silva Andrade Crispim    | 3      | Em andamento    |
| Recarga e saldo                             | Maria Luiza Macedo Bezerra      | 5      | Em andamento    |
| Extrato e Histórico                         | Maria Luiza Macedo Bezerra      | 3      | Em andamento    |
| Visualizar cardápio da refeição atual       | Ana Sarah Nagata                | 1      | Em andamento    |
| Cadastro de usuário                         | Ana Sarah Nagata                | 3      | Em andamento    |

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

---

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

---

## 4. Declaração de Uso de Inteligência Artificial

Em conformidade com as diretrizes da disciplina de Engenharia de Software:

- **Ferramenta Utilizada:** Antigravity / Gemini.
- **Partes do Projeto:** Apoio na estruturação inicial dos step definitions em Cucumber (`validacao_entrada_steps.rb` e `exportar_historico_pdf_steps.rb`), desenho da classe de serviço para geração de PDF com a gem Prawn (`gerador_historico_pdf.rb`) e montagem dos testes unitários em RSpec.
- **Estratégia Adotada:** Pair programming assistido por IA com foco em metodologia TDD/BDD. Cada método, consulta ao banco e validação foi revisado, ajustado e executado iterativamente no terminal pelo desenvolvedor Arthur Santos Almeida, assegurando total domínio sobre a arquitetura do código e capacidade de explicabilidade técnica de cada componente.

### Declaração de Uso de IA — João Pedro Rabelo do Nascimento

- **Ferramenta Utilizada:** Copilot e Claude.
- **Partes do Projeto:** Apoio na elaboração e ajuste dos steps Cucumber de gestão de restaurantes e catracas e do histórico local; configuração do workflow de CI para executar RuboCop, RSpec e Cucumber; e configuração da rota inicial para exibir a listagem de restaurantes.
- **Uso da ferramenta:** A IA foi utilizada como apoio para explicar o código, sugerir e aplicar alterações. A validação final das mudanças e a compreensão do código permaneceram sob minha responsabilidade.
