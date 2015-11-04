require "admin_constraints"
require 'sidekiq/web'

Rails.application.routes.draw do

  ## Resources
  ## ------------------------------
  namespace :admins do
    resources :admins, except: :show do
      collection do
        resource :sessions, only: [:new, :create, :destroy]
      end
    end
    resources :events, only: [:index, :show, :new, :create, :edit, :update] do
      member do
        post :remove_logo
        post :remove_background
      end
      scope module: 'events' do
        resources :admissions, only: [:destroy]
        resource :gtag_settings, only: [:show, :edit, :update]
        resource :payment_settings, only: [:show, :edit, :update]
        resource :refund_settings, only: [:show, :edit, :update] do
          member do
            post :notify_customers
          end
        end
        resources :entitlements, except: :show
        resources :ticket_types, except: :show
        resources :tickets do
          resources :comments, module: :tickets
          collection do
            get :search
            delete :destroy_multiple
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
      end
    end
    constraints AdminConstraints.new(scope: :admin) do
      mount Sidekiq::Web, at: '/sidekiq'
    end
  end

  get 'admins', to: 'admins/events#index', as: :admin_root
end
