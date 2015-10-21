Rails.application.routes.draw do

  scope module: 'events' do
    resources :events, only: [:show], path: '/' do
      devise_for :customers,
        controllers: {
          sessions: 'events/sessions',
          registrations: 'events/registrations',
          confirmations: 'events/confirmations',
          passwords: 'events/passwords'
        },
        path: '/',
        path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' }
      resources :admissions, only: [:new, :create, :destroy]
      resources :gtag_registrations, only: [:new, :create, :destroy]
      resources :checkouts, only: [:new, :create]
      resources :orders, only: [:show, :update]
      resources :epg_claims, only: [:new, :create]
      resources :bank_account_claims, only: [:new, :create]
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

  root to: 'customers/dashboards#show'
end
