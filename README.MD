# Sistema de Gestão do Restaurante Universitário da UnB

Aplicação web Rails para apoiar a gestão dos restaurantes universitários, catracas e histórico de acessos.

## Tecnologias

- Ruby 3.4.11 (versão definida em `.ruby-version`)
- Rails 8.1.4
- SQLite
- RSpec, Cucumber e RuboCop

## Pré-requisitos

- Ruby 3.4.11
- Bundler 2.6.9

Confira as versões instaladas:

```bash
ruby --version
bundle --version
```

## Instalação e execução

Na raiz do projeto, instale as gems e prepare o banco de dados:

```bash
bundle install
bin/rails db:prepare
```

Inicie o servidor Rails:

```bash
bin/rails server
```

Acesse [http://localhost:3000](http://localhost:3000). A página inicial mostra a lista de restaurantes. Encerre o servidor com `Ctrl+C`.

## Testes e lint

Execute os testes RSpec:

```bash
bundle exec rspec
```

Execute todos os cenários Cucumber:

```bash
bundle exec cucumber
```

Para executar um arquivo de feature específico:

```bash
bundle exec cucumber features/gerenciar_restaurantes.feature
bundle exec cucumber features/historico_catraca.feature
```

Execute o RuboCop:

```bash
bundle exec rubocop
```

O GitHub Actions também executa RuboCop, RSpec e Cucumber em pull requests e em pushes para `main`.
