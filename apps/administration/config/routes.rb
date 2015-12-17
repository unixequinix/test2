require "admin_constraints"
require 'sidekiq/web'

Rails.application.routes.draw do
  ## Resources
  ## ------------------------------
  namespace :admins do
    resources :locale do
      member do
        get 'change'
      end
    end
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
        #resources :admissions, only: [:destroy]
        resources :ticket_assignments, only: [:destroy], controller: "/admins/events/ticket_assignments"
        resource :gtag_settings, only: [:show, :edit, :update]
        resources :gtags do
          resources :comments, module: :gtags
          collection do
            get :search
            delete :destroy_multiple
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
        #resources :gtag_registrations, only: [:destroy]
        resources :gtag_assignments, only: [:destroy], controller: "/admins/events/gtag_assignments"
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
        resources :customers, except: [:new, :create, :edit, :update] do
          resources :ticket_assignments, only: [:new, :create], controller: "/admins/events/ticket_assignments"
          resources :gtag_assignments, only: [:new, :create], controller: "/admins/events/gtag_assignments"
          collection do
            get :search
          end
          member do
            post :resend_confirmation
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
