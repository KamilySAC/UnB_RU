Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "restaurantes#index"

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
end
