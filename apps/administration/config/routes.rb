require "admin_constraints"
require "sidekiq/web"

Rails.application.routes.draw do
  ## Resources
  ## ------------------------------
  namespace :admins do
    resources :locale do
      member do
        get "change"
      end
    end

    resources :companies do
      scope module: "companies" do
        resources :company_event_agreements, only: [:index, :new, :create] do
          member do
            get :grant_agreement
            delete :revoke_agreement
          end
        end
      end
    end

    resources :devices, only: [:index, :show, :update] do
      collection do
        get :search
        post :import
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

      scope module: "events" do
        resource :device_settings, only: [:show, :edit, :update]
        resources :ticket_assignments, only: [:destroy]
        resource :gtag_settings, only: [:show, :edit, :update]
        resource :gtag_keys, only: [:show, :edit, :update]
        resources :customer_credits, only: [:update]
        resources :devices, only: :index do
          collection do
            get :tracker
          end
        end

        resources :gtags do
          resources :comments, module: :gtags
          member do
            get :ban
            delete :unban
          end
          collection do
            get :search
            delete :destroy_multiple
            post :import
          end
        end

        resources :gtag_assignments, only: [:destroy]
        resources :ticket_types, except: :show

        resources :tickets do
          resources :comments, module: :tickets
          member do
            get :ban
            delete :unban
          end
          collection do
            get :search
            get :sample_csv
            delete :destroy_multiple
            post :import
          end
        end

        resources :companies, except: :show
        resources :products do
          collection do
            post :import
            get :sample_csv
            delete :destroy_multiple
          end
        end
        resources :catalog_items, only: :update
        resources :accesses do
          member do
            get :create_credential
            delete :destroy_credential
          end
        end
        resources :credits do
          member do
            get :create_credential
            delete :destroy_credential
          end
        end
        resources :vouchers, except: :show do
          member do
            get :create_credential
            delete :destroy_credential
          end
        end
        resources :packs do
          member do
            get :create_credential
            delete :destroy_credential
          end
        end
        resources :stations do
          resources :station_items do
            put :sort, on: :collection
          end
        end

        resources :credential_types, except: :show
        resources :company_ticket_types, except: :show

        resources :customers, except: [:new, :create, :edit, :update] do
          resources :ticket_assignments, only: [:new, :create]
          resources :gtag_assignments, only: [:new, :create]
          get :search, on: :collection
          put :reset_password, on: :member
        end

        resources :profiles, except: [:new, :create, :edit, :update] do
          member do
            get :fix_transaction
            get :ban
            delete :unban
            delete :revoke_agreement
          end
          collection do
            get :search
          end
        end
      end
    end
    constraints AdminConstraints.new(scope: :admin) do
      mount Sidekiq::Web, at: "/sidekiq"
    end
  end

  get "admins", to: "admins/events#index", as: :admin_root
end
