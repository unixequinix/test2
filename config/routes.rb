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

  ## Resources
  ## ------------------------------

  namespace :customers do
    resources :admissions, only: [:new, :create, :destroy]
    resources :orders, only: [:new, :create, :show]
    resources :payments do
      collection do
        get 'success'
        get 'error'
      end
    end
  end

  namespace :admins do
    resources :entitlements, except: :show
    resources :ticket_types, except: :show
    resources :tickets, except: :show do
      collection do
        post :import
        post :search
      end
    end
    resources :online_products, except: :show
  end

  devise_scope :customers do
    root to: 'customers/dashboards#show', as: :customer_root
  end

  devise_scope :admins do
    get 'admins', to: 'admins/dashboards#show', as: :admin_root
  end

  root to: 'customers/sessions#new'

end
