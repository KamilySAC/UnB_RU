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
- Não pode haver dois restaurantes ativos com o mesmo nome.
- Cada catraca deve pertencer a um restaurante existente.


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

## Issue Cadastro de Usuário

- O estudante se cadastra informando matrícula, nome completo e senha (com confirmação).
- Todos os campos são obrigatórios; se algum estiver vazio, a conta não é criada.
- A senha e a confirmação de senha devem ser iguais.
- Não pode haver duas contas com a mesma matrícula; se a matrícula já estiver cadastrada, a conta não é criada.
- Quando o cadastro é concluído, a conta é criada e uma mensagem de confirmação é exibida.

## Issue Autenticação de funcionário

- O funcionário se autentica no aplicativo informando a matrícula SIAPE/nome e a senha.
- A matrícula SIAPE/nome e a senha são obrigatórios; se algum estiver vazio, o login não é realizado e o sistema informa qual campo é obrigatório.
- Se o identificador não estiver cadastrado ou a senha estiver incorreta, o login é recusado com a mensagem de credenciais inválidas.
- Após o login, o fiscal é direcionado à tela "Configuração de Ponto de Acesso", onde aparecem seu nome e sua matrícula como funcionário autenticado.
- A sessão autenticada dá acesso às telas "Configuração de Ponto", "Terminal de Validação" e "Histórico Local".
- O fiscal pode alternar a visibilidade da senha durante o preenchimento (exibida em texto ou oculta).
- Ao fazer logout, a sessão é encerrada e o fiscal retorna à tela "Autenticação do Operador".

## Issue Recarga e Saldo
- O estudante precisa estar logado para adicionar créditos à conta.
A recarga pode ser feita por PIX (geração de QR Code no valor desejado) ou por cartão de crédito.
- O saldo só é atualizado após a confirmação do pagamento (PIX pago ou cartão aprovado), somando o valor da recarga ao saldo atual.
- Após uma recarga bem-sucedida, uma mensagem de sucesso é exibida.
Se os dados do cartão forem inválidos, a recarga não é realizada, uma mensagem de erro é exibida e o saldo permanece inalterado.



## Funcionalidades e Responsáveis

| Funcionalidade                    | Responsável                     | Pontos |
| --------------------------------- | ------------------------------- | ------ |
| Gestão de Restaurantes e Catracas | João Pedro Rabelo do Nascimento | 5      |
| Validação de Entrada na Catraca   | Arthur Santos Almeida           | 8      |
| Autenticação do funcionário       | Kamily Silva Andrade Crispim    | 3      |
| Cadastro de usuário               | Ana Sarah Nagata                | 3      |
| Recarga e saldo                   | Maria Luiza Macedo Bezerra      | 5      |
| Validação de Entrada na Catraca   | Maria Luiza Macedo Bezerra      | 3      |