# Wiki - Sprint 1

**Projeto:** UnB-Ru

## Integrantes

| Nome                            | Matrícula | Papel         |
| ------------------------------- | --------- | ------------- |
| Ana Sarah Nagata                |           |               |
| Kamily Silva Andrade Crispim    |           |               |
| João Pedro Rabelo do Nascimento | 241036160 | Desenvolvedor |
| Maria Luiza Macedo Bezerra      |           |               |
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
- O usuário só pode utilizar uma refeição por turno (regra de anti-passback).
- O sistema calcula a tarifa conforme o perfil do usuário (Resolução nº 0037/2025 do CAD/UnB):
  - Grupo I (Subsídio Integral / 100% gratuito): Estudantes PNAES (até 1,5 SM), CadÚnico, Cota Escola Pública Baixa Renda, Indígenas, Quilombolas, LedoC, PEC-PLE, PEC-G, Mobilidade e Cota Trans. Tarifa: R$ 0,00 (libera sem exigir saldo).
  - Grupo II (Graduação, Pós stricto sensu, Estagiários DGP, Residentes): Café da manhã R$ 2,00 | Almoço e Jantar R$ 4,50.
  - Grupo III (Servidores, Terceirizados e Visitantes): Café da manhã R$ 7,05 | Almoço e Jantar R$ 15,20.
  - Grupo IV (Graduação Cotas Escola Pública - Exceto Baixa Renda): Café da manhã R$ 1,50 | Almoço e Jantar R$ 2,50.
- Usuários pagantes (Grupos II, III e IV) precisam ter saldo igual ou superior ao valor da tarifa correspondente ao turno.
- O débito no saldo e o registro do acesso ocorrem apenas no momento do giro físico da catraca.
- Caso ocorra timeout (5 segundos) sem giro após a liberação, a catraca volta a bloquear e nenhum valor é debitado.
- Leituras duplicadas do cartão enquanto a catraca aguarda o giro são desconsideradas para evitar cobrança em duplicidade.

## Funcionalidades e Responsáveis

| Funcionalidade                    | Responsável                     | Pontos |
| --------------------------------- | ------------------------------- | ------ |
| Gestão de Restaurantes e Catracas | João Pedro Rabelo do Nascimento | 3      |
| Validação de Entrada na Catraca   | Arthur Santos Almeida           | 5      |
