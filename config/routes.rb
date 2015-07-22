require 'api_constraints'
require 'sidekiq/web'

Rails.application.routes.draw do

  ## Devise
  ## ------------------------------

  devise_for :admins,
    controllers: {
      sessions: 'admins/sessions',
      passwords: 'admins/passwords'
    },
    path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' }

  devise_for :customers,
    controllers: {
      sessions: 'customers/sessions',
      registrations: 'customers/registrations',
      confirmations: 'customers/confirmations',
      passwords: 'customers/passwords'
    },
    path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' }

  resources :locale do
    member do
      get 'change'
    end
  end

  ## API
  ## ------------------------------

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1,
          constraints: ApiConstraints.new(version: 1, default: true) do
      resources :customers, only: [:index]
      resources :orders, only: [:index]
      resources :tickets, only: [:index]
      resources :refunds, only: [:index]
    end
  end

  ## Resources
  ## ------------------------------

  namespace :customers do
    resources :admissions, only: [:new, :create, :destroy]
    resources :refunds, only: [:new, :create, :edit, :update]
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

  namespace :admins do
    resources :admins, except: :show
    resources :admissions, only: [:destroy]
    resources :events, only: [:show, :edit, :update] do
      member do
        post :remove_logo
        post :remove_background
      end
      resource :refund_settings, only: [:show, :edit, :update] do
        member do
          post :notify_customers
        end
      end
    end
    resources :entitlements, except: :show
    resources :ticket_types, except: :show do
      collection do
        post :import
      end
    end
    resources :tickets do
      collection do
        post :import
        get :search
        delete :destroy_multiple
        delete :clean_tickets
      end
    end
    resources :gtags do
      collection do
        post :import
        post :import_credits
        get :search
        delete :destroy_multiple
        delete :clean_gtags
        delete :clean_credits
      end
    end
    resources :credits, except: :show
    resources :gtag_registrations, only: [:destroy]
    resources :customers, except: [:new, :create, :edit, :update] do
      resources :admissions, only: [:new, :create]
      resources :gtag_registrations, only: [:new, :create]
      collection do
        get :search
      end
      member do
        post :resend_confirmation
      end
    end
    resources :orders, except: [:new, :create, :edit, :update] do
      collection do
        get :search
      end
    end
    resources :payments, except: [:new, :create, :edit, :update] do
      collection do
        get :search
      end
    end
    resources :claims, except: [:new, :create, :edit] do
      collection do
        get :search
      end
    end
    resources :refunds, except: [:new, :create, :edit] do
      collection do
        get :search
      end
    end
    authenticate :admin do
      mount Sidekiq::Web, at: '/sidekiq'
    end
  end


  devise_scope :customers do
    root to: 'customers/dashboards#show', as: :customer_root
  end

  devise_scope :admins do
    get 'admins', to: 'admins/dashboards#show', as: :admin_root
  end



  root to: 'customers/sessions#new'

end
