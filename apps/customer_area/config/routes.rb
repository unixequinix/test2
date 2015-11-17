Rails.application.routes.draw do

  scope module: 'events' do
    resources :events, only: [:show], path: '/' do
      get "signin", to: "registrations#new"
      get "login", to: "sessions#new"
      delete "logout", to: "sessions#destroy"
      resources :customers do
        collection do
          resource :registrations, only: [:new, :create, :edit, :update]
          resource :sessions, only: [:new, :create, :destroy]
          resource :confirmations, only: [:new, :create, :show]
          resource :passwords, only: [:new, :create, :edit, :update]
        end
      end
      resources :admissions, only: [:new, :create, :destroy]
      resources :gtag_registrations, only: [:new, :create, :destroy]
      resources :checkouts, only: [:new, :create]
      get 'privacy_policy', to: 'static_pages#privacy_policy'
      get 'terms_of_use', to: 'static_pages#terms_of_use'
    end
  end

  get ':event_id', to: 'events/events#show', as: :customer_root
end
