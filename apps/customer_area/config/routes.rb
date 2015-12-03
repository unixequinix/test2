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
      resources :orders, only: [:show, :update]
      resources :payments, only: [:create]
      # resources :payments, only: [:create], constraints: lambda{|request|request.env['HTTP_X_REAL_IP'].match(Rails.application.secrets.merchant_ip)}
      resources :payments, except: [:index, :show, :new, :create, :edit, :update, :destroy] do
        collection do
          get 'success'
          get 'error'
        end
      end
      resources :refunds, only: [:create]
      # resources :refunds, only: [:create], constraints: lambda{|request|request.env['HTTP_X_REAL_IP'].match(Rails.application.secrets.merchant_ip)}
      resources :refunds, except: [:index, :show, :new, :create, :edit, :update, :destroy] do
        collection do
          get 'success'
          get 'error'
        end
      end
      get 'privacy_policy', to: 'static_pages#privacy_policy'
      get 'terms_of_use', to: 'static_pages#terms_of_use'
    end
  end

  get ':event_id', to: 'events/events#show', as: :customer_root
end
