Rails.application.routes.draw do
  # API namespaced routes for frontend
  namespace :api do
    namespace :v1 do
      post "login", to: "auth#login"
      get "me", to: "users#me"

      resources :clients, only: [:index, :show, :create, :update, :destroy]

      resource :account, only: [:show, :update]
      resources :accounts, only: [:index, :show, :create, :update, :destroy]

      resources :resources, only: [:index, :show, :create, :update, :destroy]
      resources :services, only: [:index, :show, :create, :update, :destroy]
      resources :appointments, only: [:index, :show, :create, :update, :destroy]
      resources :notes, only: [:index, :show, :create, :update, :destroy]

      get "dashboard", to: "users#dashboard"

      resources :users, only: [:index, :show, :create, :update, :destroy] do
        get "dashboard", on: :member
      end
    end
  end
end