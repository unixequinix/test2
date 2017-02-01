require "sidekiq/web"

Rails.application.routes.draw do
  get "/admins", to: "admins/events#index", as: :admin_root
  get ":event_id", to: "events/events#show", as: :customer_root

  #----------------------------------------------------------
  # Admin panel
  #----------------------------------------------------------
  devise_for :users, controllers: { sessions: "admins/sessions"}

  resources :users

  namespace :admins do
    resources :devices, only: [:index, :show, :edit, :update, :destroy]

    namespace :eventbrite do
      get :auth
    end

    resources :locale do
      get :change, on: :member
    end
    resources :companies do
      scope module: "companies" do
        resources :company_event_agreements, only: [:index, :create, :destroy]
      end
    end
    resources :events, except: :destroy do
      member do
        post :remove_logo
        post :remove_background
        get :create_admin
        get :create_customer_support
        get :transactions_chart
        get :credits_chart
      end

      scope module: "events" do
        resources :refunds, only: [:index, :show]
        resources :orders, only: [:index, :show]
        resources :gtag_assignments, only: :destroy
        resources :ticket_types, except: :show
        resources :devices, only: :index
        resources :asset_trackers
        resources :credits, except: [:new, :create]
        resources :catalog_items, only: :update
        resources :accesses
        resources :packs
        resources :ticket_assignments, only: :destroy
        resources :companies, except: :show
        resources :users

        # Eventbrite
        get "eventbrite", to: "eventbrite#index"
        get "eventbrite/import_tickets", to: "eventbrite#import_tickets"
        get "eventbrite/disconnect", to: "eventbrite#disconnect"
        get "eventbrite/connect/:eb_event_id", to: "eventbrite#connect", as: 'eventbrite_connect'
        post "eventbrite/webhooks", to: "eventbrite#webhooks"

        resources :inconsistencies do
          collection do
            get :missing
            get :real
            get :resolvable
          end
        end
        resources :transactions, only: [:index, :show, :update] do
          post :search, on: :collection
          get :fix, on: :member
        end
        resources :payment_gateways, except: :show do
          member do
            post :topup
            post :refund
          end
        end
        resources :customers, only: [:index, :show] do
          member do
            resources :ticket_assignments, only: [:new, :create]
            resources :gtag_assignments, only: [:new, :create]
            get :download_transactions
            get :reset_password
          end
        end
        resource :device_settings, only: [:show, :edit, :update] do
          member do
            delete :remove_db
            get :load_defaults
          end
        end
        resource :gtag_settings, only: [:show, :edit, :update] do
          get :load_defaults, on: :member
        end
        resources :gtags do
          member do
            get :recalculate_balance
            get :ban
            get :solve_inconsistent
            get :unban
          end
          collection do
            get :sample_csv
            post :import
          end
        end
        resources :tickets do
          member do
            get :ban
            get :unban
          end
          collection do
            get :sample_csv
            post :import
          end
        end
        resources :products do
          collection do
            post :import
            get :sample_csv
          end
        end
        resources :stations do
          post :clone
          post :visibility
          resources :station_items do
            put :sort, on: :collection
            post :visibility
          end
        end
        resources :ticket_types, except: :show do
          post :visibility
        end
      end
    end

    mount Sidekiq::Web, at: "/sidekiq"
  end

  #----------------------------------------------------------
  # Customer Area
  #----------------------------------------------------------
  devise_for :customers, skip: [:session, :password, :registration, :confirmation], controllers: { omniauth_callbacks: "events/omniauth_callbacks" }
  scope module: "events" do
    resources :events, only: [:show], path: "/" do
      devise_for :customers, skip: :omniauth_callbacks

      devise_scope :customer do
        get "/login", to: "sessions#new"
        post "/login", to: "sessions#create"
        delete "/logout", to: "sessions#destroy"
        get "/register", to: "registrations#new"
        get "/account", to: "registrations#edit"
        post "/register", to: "registrations#create"
        patch "/register", to: "registrations#update"
        get "/recover_password", to: "passwords#new"
        post "/recover_password", to: "passwords#create"
        get "/edit_password", to: "passwords#edit"
        patch "/edit_password", to: "passwords#update"
      end

      get "signin", to: "registrations#new"
      get "login", to: "sessions#new"
      delete "logout", to: "sessions#destroy"

      resource :info
      resources :locale do
        member do
          get "change"
        end
      end

      resources :ticket_assignments, only: [:new, :create, :destroy]
      resources :gtag_assignments, only: [:new, :create, :destroy]
      resources :tickets, only: [:show]
      resources :orders, expect: :destroy
      get "credits_history", to: "credits_histories#history"
      get "privacy_policy", to: "static_pages#privacy_policy"
      get "terms_of_use", to: "static_pages#terms_of_use"

      # Paypal
      get :paypal_setup_purchase, to: "paypal#setup_purchase"
      get :paypal_purchase, to: "paypal#purchase"
      post :paypal_refund, to: "paypal#refund"

      # Redsys
      post :redsys_purchase, to: "redsys#purchase"
      post :redsys_refund, to: "redsys#refund"

      # Stripe
      post :stripe_purchase, to: "stripe#purchase"
      post :stripe_refund, to: "stripe#refund"

      # Wirecard
      post :wirecard_purchase, to: "wirecard#purchase"
      post :wirecard_refund, to: "wirecard#refund"

      # Bank Account
      resources :refunds
    end
  end

  #----------------------------------------------------------
  # API
  #----------------------------------------------------------
  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :devices, only: [:create]
      resources :events, only: :index do
        scope module: "events" do
          resource :database, only: [:create, :show]
          resources :accesses, only: :index
          resources :auto_top_ups, only: :create
          resources :backups, only: :create
          resources :ticket_types, only: :index
          resources :credits, only: :index
          resources :customers, only: [:index, :show]
          resources :orders, only: :index
          resources :packs, only: :index
          resources :parameters, only: :index
          resources :products, only: :index
          resources :stations, only: :index
          resources :transactions, only: :create
          resources :device_transactions, only: :create
          resources :user_flags, only: :index
          resources :tickets, only: [:index, :show] do
            get :banned, on: :collection
          end
          resources :gtags, only: [:index, :show] do
            get :banned, on: :collection
          end
          get "/time", to: "time#index"
        end
      end
    end
  end

  ##----------------------------------------------------------
  # Thirdparty API
  #----------------------------------------------------------
  namespace :companies do
    namespace :api, defaults: { format: "json" } do
      namespace :v1 do
        resources :banned_tickets, path: "tickets/blacklist", only: [:index, :create, :destroy]
        resources :tickets, only: [:index, :show, :create, :update] do
          post :bulk_upload, on: :collection
        end
        resources :ticket_types, only: [:index, :show, :create, :update]
        resources :balances, only: :show
      end
    end
  end
end
