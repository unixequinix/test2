require "sidekiq/web"

Rails.application.routes.draw do
  get "/admins", to: "admins/events#index", as: :admin_root
  get ":event_id", to: "events/events#show", as: :customer_root

  #----------------------------------------------------------
  # Admin panel
  #----------------------------------------------------------
  devise_for :admins

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

    resources :devices, only: [:index, :show, :update, :destroy] do
      collection do
        get :search
      end
    end

    resources :admins, except: :show  do
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
        # Credit inconsistencies
        resources :credit_inconsistencies do
          collection do
            get :missing
            get :real
          end
        end

        # Transactions
        resources :transactions, only: [:index, :show, :update] do
          collection do
            get :search
          end
        end

        # Refunds
        resources :refunds, except: [:new, :create, :edit] do
          collection do
            get :search
          end
        end

        resources :refund_settings, only: [:index, :edit, :update] do
          collection do
            get :edit_messages
            patch :update_messages
            post :notify_customers
          end
        end

        # Claims
        resources :claims, except: [:new, :create, :edit] do
          collection do
            get :search
          end
        end

        # Payments
        resources :payment_settings, only: [:index, :new, :create, :edit, :update]

        resources :payments, except: [:new, :create, :edit, :update] do
          collection do
            get :search
          end
        end

        # Orders
        resources :orders, except: [:new, :create, :edit, :update] do
          collection do
            get :search
          end
        end

        # Customers
        resources :customers do
          collection do
            get :search
          end
        end

        # Eventbrite
        get 'eventbrite', to: "eventbrite#index"
        get 'eventbrite/auth', to: "eventbrite#auth"
        patch 'eventbrite/connect', to: "eventbrite#connect"
        get 'eventbrite/disconnect', to: "eventbrite#disconnect"
        get 'eventbrite/import_tickets', to: "eventbrite#import_tickets"

        resource :device_settings, only: [:show, :edit, :update] do
          member do
            delete :remove_db
          end
        end
        resources :ticket_assignments, only: [:destroy]
        resource :gtag_settings, only: [:show, :edit, :update]
        resource :gtag_keys, only: [:show, :edit, :update]
        resources :devices, only: :index
        resources :asset_trackers

        resources :gtags do
          resources :comments, module: :gtags
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
            get :search
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
          post :clone
          resources :station_items do
            put :sort, on: :collection
          end
        end

        resources :credential_types, except: :show
        resources :company_ticket_types, except: :show

        resources :profiles, except: [:new, :create, :edit, :update] do
          member do
            resources :ticket_assignments, only: [:new, :create]
            resources :gtag_assignments, only: [:new, :create]
            get :download_transactions
            get :fix_transaction
            get :ban
            put :reset_password
            delete :unban
            delete :revoke_agreement
          end
          collection do
            get :search
          end
        end
      end
    end

    mount Sidekiq::Web, at: "/sidekiq"
  end

  #----------------------------------------------------------
  # API
  #----------------------------------------------------------
  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :devices, only: [:create]
      resources :events, only: :index do
        scope module: "events" do
          resources :accesses, only: :index
          resources :auto_top_ups, only: :create
          resources :backups, only: :create
          resources :banned_gtags, path: "gtags/banned", only: :index
          resources :banned_tickets, path: "tickets/banned", only: :index
          resource :database, only: [:create, :show]
          resources :company_ticket_types, only: :index
          resources :credential_types, only: :index
          resources :credits, only: :index
          resources :customers, only: [:index, :show]
          resources :gtags, only: [:index, :show]
          resources :orders, only: :index
          resources :packs, only: :index
          resources :parameters, only: :index
          resources :products, only: :index
          resources :stations, only: :index
          resources :tickets, only: [:index, :show]
          resources :transactions, only: :create
          resources :vouchers, only: :index
          get "/time", to: "time#index"
        end
      end
    end
  end

  #----------------------------------------------------------
  # Customer Area
  #----------------------------------------------------------
  scope module: "events" do
    resources :events, only: [:show], path: "/" do
      devise_for :profiles
      devise_scope :profile do
        get "/login", to: "sessions#new"
        post "/login", to: "sessions#create"
        delete "/logout", to: "sessions#destroy"
        get "/register", to: "registrations#new"
        get "/profile", to: "registrations#edit"
        post "/register", to: "registrations#create"
        patch "/register", to: "registrations#update"
        get "/change_password", to: "registrations#change_password"
        patch "/change_password", to: "registrations#update_password"
      end

      resource :info
      resources :locale do
        member do
          get "change"
        end
      end

      resources :autotopup_agreements, only: [:new, :show, :update, :destroy]
      resources :ticket_assignments, only: [:new, :create, :destroy]
      resources :gtag_assignments, only: [:new, :create, :destroy]
      resources :checkouts, only: [:new, :create]
      resources :credential_types, only: [:show]
      get "credits_history", to: "credits_histories#download"
      get "privacy_policy", to: "static_pages#privacy_policy"
      get "terms_of_use", to: "static_pages#terms_of_use"
      resources :orders, only: [:show, :update] do
        resources :payment_services, only: [] do
          resources :autotopup_synchronous_payments, only: [:new, :create] do
            collection do
              get "success"
              get "error"
            end
          end
          resources :autotopup_asynchronous_payments, only: [:new, :create] do
            collection do
              get "success"
              post "success"
              get "error"
              post "error"
            end
          end
          resources :synchronous_payments, only: [:new, :create] do
            collection do
              get "success"
              get "error"
            end
          end
          resources :asynchronous_payments, only: [:new, :create] do
            collection do
              get "success"
              post "success"
              get "error"
              post "error"
            end
          end
        end
      end

      resources :refunds, only: [:create] do
        collection do
          get "success"
          get "error"
          get "tipalti_success"
        end
      end
      resources :epg_claims, only: [:new, :create]
      resources :bank_account_claims, only: [:new, :create]
      resources :tipalti_claims, only: [:new]
      resources :direct_claims, only: [:new, :create]
    end
  end

  ##----------------------------------------------------------
  # Thirdparty API
  #----------------------------------------------------------
  namespace :companies do
    namespace :api, defaults: { format: "json" } do
      namespace :v1 do
        resources :banned_tickets, path: "tickets/blacklist", only: [:index, :create, :destroy]
        resources :banned_gtags, path: "gtags/blacklist", only: [:index, :create, :destroy]
        resources :gtags, only: [:index, :show, :create, :update]
        resources :tickets, only: [:index, :show, :create, :update] do
          post :bulk_upload, on: :collection
        end
        resources :ticket_types, only: [:index, :show, :create, :update]
        resources :balances, only: :show
      end
    end
  end
end
