Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "dashboard", to: "dashboard#show", as: :dashboard

  get  "recarga",               to: "recargas#new",             as: :recarga
  post "recarga/pix",           to: "recargas#create_pix",      as: :recarga_pix
  post "recarga/pix/confirmar", to: "recargas#confirmar_pix",   as: :recarga_pix_confirmar
  post "recarga/cartao",        to: "recargas#create_cartao",   as: :recarga_cartao

  get "extrato/recargas",     to: "extratos#recargas",        as: :extrato_recargas
  get "extrato/recargas/:id", to: "extratos#detalhe_recarga", as: :detalhe_recarga
  get "extrato/refeicoes",    to: "extratos#refeicoes",       as: :extrato_refeicoes
  get "meus_gastos",          to: "extratos#painel",          as: :painel

  resources :restaurantes, except: :show do
    resources :catracas, only: %i[new create]
  end

  resources :catracas, only: %i[edit update destroy] do
    resources :acessos, only: %i[index new create]
  end

  get "historico/exportar_pdf",
      to: "historicos#exportar_pdf",
      as: :exportar_historico_pdf

    get  "cadastro", to: "estudantes#new", as: :cadastro
  post "cadastro", to: "estudantes#create"

  # autenticação do funcionário (fiscal e administrador)
  get    "funcionario/login",  to: "funcionario_sessions#new",     as: :login_funcionario
  post   "funcionario/login",  to: "funcionario_sessions#create"
  delete "funcionario/logout", to: "funcionario_sessions#destroy", as: :logout_funcionario

  # telas do aplicativo (exigem funcionário autenticado)
  get "ponto-de-acesso",       to: "painel#configuracao_ponto", as: :configuracao_ponto
  get "terminal-de-validacao", to: "painel#terminal_validacao", as: :terminal_validacao
  get "historico-local",       to: "painel#historico_local",    as: :historico_local

  # histórico global de acessos do campus (somente administrador)
  get "historico-global",      to: "historico_global#index",    as: :historico_global

  root "sessions#new"
end

