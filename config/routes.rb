Rails.application.routes.draw do
  root "home#index"

  resources :users, only: %i[new create]

  resource :session, only: %i[new create destroy]

  resources :usual_routes, only: %i[index show new create edit update destroy] do
    resources :timetables, only: %i[index new create edit update]
  end

  get "my_page", to: "my_page#show"
  get "next_departures", to: "next_departures#index"
end
