Rails.application.routes.draw do
  root "home#index"

  resources :users, only: %i[new create]

  resource :session, only: %i[new create destroy]
end
