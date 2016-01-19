require 'admin_constraints'
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
        resources :ticket_assignments, only: [:destroy]
        resource :gtag_settings, only: [:show, :edit, :update]
        resources :gtags do
          resources :comments, module: :gtags
          collection do
            get :search
            delete :destroy_multiple
          end
        end
        resources :ticket_types, except: :show
        resources :tickets do
          resources :comments, module: :tickets
          collection do
            get :search
            delete :destroy_multiple
          end
        end
        resources :gtag_assignments, only: [:destroy]
        resources :ticket_types, except: :show
        resources :tickets do
          resources :comments, module: :tickets
          collection do
            get :search
            delete :destroy_multiple
          end
        end
        resources :companies, except: :show
        resources :credits, except: :show
        resources :vouchers, except: :show
        resources :credential_types, except: :show
        resources :preevent_products, except: :show
        resources :company_ticket_types, except: :show
        resources :customers, except: [:new, :create, :edit, :update] do
          resources :ticket_assignments, only: [:new, :create]
          resources :gtag_assignments, only: [:new, :create]
          collection do
            get :search
          end
          member do
            post :resend_confirmation
          end
        end
        resources :customer_event_profiles, except: [:new, :create, :edit, :update] do
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
