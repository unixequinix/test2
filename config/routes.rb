require 'api_constraints'

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
    resources :payments, only: [:create] do
      collection do
        get 'success'
        get 'error'
      end
    end
  end

  namespace :admins do
    resources :events, only: :update
    resources :entitlements, except: :show
    resources :ticket_types, except: :show
    resources :tickets, except: :show do
      collection do
        post :import
        post :search
      end
    end
    resources :gtags, except: :show do
      collection do
        post :import
        post :search
      end
    end
    resources :credits, except: :show
    resources :customers, except: [:new, :create, :edit, :update] do
      collection do
        post :search
      end
    end
    resources :orders, except: [:new, :create, :edit, :update] do
      collection do
        post :search
      end
    end
    resources :payments, except: [:new, :create, :edit, :update] do
      collection do
        post :search
      end
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
