Rails.application.routes.draw do
  root "home#index"

  resources :users, only: %i[new create]

  resource :session, only: %i[new create destroy]

  resources :usual_routes, only: %i[new create]

  get "my_page", to: "my_page#show"
end
