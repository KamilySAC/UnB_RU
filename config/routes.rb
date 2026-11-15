Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :restaurantes, except: :show do
    resources :catracas, only: %i[new create]
  end
  resources :catracas, only: %i[edit update destroy] do
    resources :acessos, only: %i[index new create]
  end
  # Defines the root path route ("/")
  # página inicial do estudante
  root "home#index"

  # rota para download dohistorico do estudante em PDF
  get "historico/exportar_pdf", to: "historicos#exportar_pdf", as: :exportar_historico_pdf

  # cadastro de estudante
  get  "cadastro", to: "estudantes#new",    as: :cadastro
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



end
