Rails.application.routes.draw do
  # API namespaced routes for frontend
  namespace :api do
    namespace :v1 do
      resources :clients, only: [:index, :show, :create, :update, :destroy]
      resources :accounts, only: [:index, :show, :create, :update, :destroy]
      resources :services, only: [:index, :show, :create, :update, :destroy]
      resources :appointments, only: [:index, :show, :create, :update, :destroy]
      resources :notes, only: [:index, :show, :create, :update, :destroy]
      resources :users, only: [:index, :show, :create, :update, :destroy] do
        get 'dashboard', on: :member
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # If you later want server-rendered HTML routes, add them outside the API namespace.
end
