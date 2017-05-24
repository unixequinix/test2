require "sidekiq/web"

Rails.application.routes.default_url_options[:host] = Rails.application.secrets.host

Rails.application.routes.draw do

  root "admins/events#index"
  get "/admins", to: "admins/events#index", as: :admin_root
  get ":event_id", to: "events/events#show", as: :customer_root

  mount ActionCable.server => '/cable'

  #----------------------------------------------------------
  # Admin panel
  #----------------------------------------------------------
  devise_for :users, controllers: { sessions: "admins/sessions"}
  devise_scope :user do
    get "/admins/sign_in", to: "admins/sessions#new"
  end

  resources :users, except: [:index, :destroy]

  namespace :admins do

    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end

    resources :users, only: [:index, :update, :destroy, :show]

    resources :devices, only: [:index, :show, :edit, :update, :destroy]

    namespace :eventbrite do
      get :auth
    end

    resources :locale do
      get :change, on: :member
    end

    resources :events do
      get :sample_event, on: :collection

      member do
        get :edit_event_style
        get :device_settings
        delete :remove_db
        get :stats
        get :launch
        get :close
        post :remove_logo
        post :remove_background
        get :create_admin
        get :create_customer_support
      end

      scope module: "events" do
        resources :refunds, only: [:index, :show, :destroy]
        resources :orders, only: [:index, :show, :new, :create, :destroy] do
          resources :order_items, only: :update
        end
        resources :gtag_assignments, only: :destroy
        resources :ticket_types
        resources :devices, only: [:index, :show] do
          get :download_db, on: :member
        end
        resources :credits, except: [:new, :create]
        resources :catalog_items, only: :update
        resources :accesses
        resources :packs
        resources :ticket_assignments, only: :destroy
        resources :companies, except: :show
        resources :event_registrations do
          get :accept, on: :member
          get :resend, on: :member
        end

        # Eventbrite
        get "eventbrite", to: "eventbrite#index"
        get "eventbrite/import_tickets", to: "eventbrite#import_tickets"
        get "eventbrite/disconnect", to: "eventbrite#disconnect"
        get "eventbrite/disconnect_event", to: "eventbrite#disconnect_event"
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
          get :status_9, on: :member
          get :status_0, on: :member
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
        resources :gtags do
          member do
            get :recalculate_balance
            get :solve_inconsistent
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
          resources :station_items, only: [:create, :update, :destroy] do
            put :sort, on: :collection
            get :find_product, on: :collection
          end
        end
        resources :ticket_types, except: :show do
          get :unban, on: :member
        end
      end
    end
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
        get "/change_password", to: "registrations#change_password"
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

      resources :locale do
        member do
          get "change"
        end
      end

      resources :ticket_assignments, only: [:new, :create, :destroy]
      resources :gtag_assignments, only: [:new, :create]
      resources :tickets, only: [:show]
      resources :gtags, only: [:show]
      resources :orders, expect: :destroy do
        get :success, on: :member
        get :error, on: :member
        get :abstract_error, on: :collection
      end

      get :credits_history, to: "credits_histories#history"
      get :privacy_policy, to: "static_pages#privacy_policy"
      get :terms_of_use, to: "static_pages#terms_of_use"

      # Paypal
      get :paypal_setup_purchase, to: "paypal#setup_purchase"
      get :paypal_purchase, to: "paypal#purchase"
      post :paypal_refund, to: "paypal#refund"
      
      # Vouchup
      get :vouchup_purchase, to: "vouchup#purchase"
      post :vouchup_success, to: "vouchup#success"
      post :vouchup_error, to: "vouchup#error"
      post :vouchup_refund, to: "vouchup#refund"

      # Bank Account
      resources :refunds
    end
  end

  #----------------------------------------------------------
  # API
  #----------------------------------------------------------
  namespace :api, defaults: { format: "json" } do

    # V2
    #---------------
    namespace :v2 do
      resources :events, only: [:show] do
        scope module: "events" do
          resources :customers, :constraints => { :id => /.*/ } do
            get :refunds, on: :member
          end
          resources :devices
          resources :companies
          resources :gtags
          resources :accesses
          resources :products
          resources :stations
          resources :tickets

          resources :refunds do
            put :complete, on: :member
          end
          resources :orders do
            put :complete, on: :member
          end
          resources :ticket_types do
            get :tickets, on: :member
          end
        end
      end
    end

    # V1
    #---------------
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

