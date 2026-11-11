Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "dashboard", to: "dashboard#show", as: :dashboard

  get  "recarga",                to: "recargas#new",             as: :recarga
  post "recarga/pix",            to: "recargas#create_pix",      as: :recarga_pix
  post "recarga/pix/confirmar",  to: "recargas#confirmar_pix",   as: :recarga_pix_confirmar
  post "recarga/cartao",         to: "recargas#create_cartao",   as: :recarga_cartao

  get "extrato/recargas",        to: "extratos#recargas",        as: :extrato_recargas
  get "extrato/recargas/:id",    to: "extratos#detalhe_recarga", as: :detalhe_recarga
  get "extrato/refeicoes",       to: "extratos#refeicoes",       as: :extrato_refeicoes
  get "meus_gastos",             to: "extratos#painel",          as: :painel

  root "sessions#new"
end
