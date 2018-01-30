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
  devise_for :users, controllers: { sessions: "admins/sessions", passwords: "admins/passwords"}

  namespace :admins do

    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end

    resources :users do
      resource :team, controller: "users/teams" do
        resources :devices, controller: "users/teams/devices", except: [:new, :create]

        get :sample_csv
        post :import_devices
        post :add_users
        post :add_devices
        put :change_role
        delete  :remove_devices
        delete :remove_users
      end
    end
    
    resources :event_series do
      member do
        put :add_event
        delete :remove_event
        get :copy_data
        post :copy_serie
      end
    end

    namespace :eventbrite do
      get :auth
    end

    namespace :universe do
      get :auth
      post :webhooks
    end

    resources :locale do
      get :change, on: :member
    end

    resources :events do
      get :sample_event, on: :collection

      member do
        get :resolve_time
        get :do_resolve_time
        delete :remove_db
        get :launch
        get :close
        post :remove_logo
        post :remove_background
        get :create_admin
        get :create_customer_support
        get :versions
        get :refund_fields
      end

      scope module: :events do

        resource :reports do
          get :money_recon
          get :cashless
          get :activations
          get :devices
          get :products_sale
          get :gates
          get :operators
        end

        resources :stats, only: [:edit, :update] do
          get :stations, on: :collection
          get :issues, on: :collection
          put :update_multiple, on: :collection
        end
        resources :alerts, only: [:index, :update, :destroy] do
          get :read_all, on: :collection
        end
        resources :refunds, only: [:index, :show, :destroy, :update]
        resources :orders, only: [:index, :show, :new, :create, :destroy] do
          resources :order_items, only: :update
        end
        resources :gtag_assignments, only: :destroy
        resources :ticket_types
        resources :device_registrations, only: [:index, :show, :destroy, :new, :create, :update] do
          get :download_db, on: :member
          get :resolve_time, on: :member
          get :transactions, on: :member
          put :disable, on: :collection
        end
        resources :credits, except: [:new, :create]
        resources :catalog_items, only: :update
        resources :accesses
        resources :devices, only: [:new, :create]
        resources :device_caches, only: :destroy
        resources :operator_permissions
        resources :packs do
          post :clone, on: :member
        end
        resources :ticket_assignments, only: :destroy
        resources :companies, except: :show
        resources :event_registrations, except: :show  do
          get :resend, on: :member
        end

        # Eventbrite
        get "eventbrite", to: "eventbrite#index"
        get "eventbrite/import_tickets", to: "eventbrite#import_tickets"
        get "eventbrite/disconnect", to: "eventbrite#disconnect"
        get "eventbrite/disconnect_event", to: "eventbrite#disconnect_event"
        get "eventbrite/connect/:eb_event_id", to: "eventbrite#connect", as: 'eventbrite_connect'
        post "eventbrite/webhooks", to: "eventbrite#webhooks"

        #Universe
        get "universe", to: "universe#index"
        get "universe/import_tickets", to: "universe#import_tickets"
        get "universe/connect/:uv_event_id", to: "universe#connect", as: 'universe_connect'
        get "universe/disconnect", to: "universe#disconnect"
        get "universe/disconnect_event", to: "universe#disconnect_event"

        resources :inconsistencies do
          collection do
            get :missing
            get :real
            get :resolvable
          end
        end

        resources :transactions, only: [:index, :show, :update, :destroy] do
          get :download_raw_transactions, on: :collection
          post :search, on: :collection
        end

        resources :pokes, only: [] do
          get :status_9, on: :member
          get :status_0, on: :member
        end

        resources :payment_gateways, except: :show

        resources :customers, only: [:index, :show, :edit, :update] do
          member do
            resources :ticket_assignments, only: [:new, :create]
            resources :gtag_assignments, only: [:new, :create]
            get :download_transactions
            get :reset_password
            get :resend_confirmation
          end
        end

        resources :gtags do
          member do
            get :recalculate_balance
            get :solve_inconsistent
          end
          collection do
            get :inconsistencies
            get :missing_transactions
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

        resources :stations do
          post :clone
          post :hide
          post :unhide
          put :add_ticket_types
          put :remove_ticket_types
          get :reports
          scope module: :stations do
            resources :products, only: [:update, :index]
            resources :station_items, only: [:create, :update, :destroy] do
              put :sort, on: :collection
              get :find_product, on: :collection
            end
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
  devise_for :customers, skip: [:session, :password, :registration, :confirmation], controllers: { omniauth_callbacks: "events/omniauth_callbacks", confirmations: 'confirmations'}

  scope module: "events" do
    resources :events, only: [:show], path: "/" do
      devise_for :customers, skip: :omniauth_callbacks

      devise_scope :customer do
        get "/login", to: "sessions#new"
        post "/login", to: "sessions#create"
        delete "/logout", to: "sessions#destroy"
        get "/resend_confirmation", to: "sessions#resend_confirmation"
        post "/send_email", to: "sessions#send_email"
        get "/register", to: "registrations#new"
        get "/account", to: "registrations#edit"
        get "/change_password", to: "registrations#change_password"
        patch "/update_password", to: "registrations#update_password"
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
      resources :gtags, only: [:show] do
        patch :ban, on: :member
      end
      resources :orders, only: [] do
        get :success, on: :member
        get :error, on: :member
        get :abstract_error, on: :collection
      end

      get :credits_history, to: "credits_histories#history"
      get :privacy_policy, to: "static_pages#privacy_policy"
      get :terms_of_use, to: "static_pages#terms_of_use"

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
          resources :devices, except: %i[create new]
          resources :companies
          resources :accesses
          resources :stats, only: %i[index show]

          resources :tickets do
            post :topup, on: :member
            post :virtual_topup, on: :member
          end

          resources :gtags do
            member do
              post :replace
              post :topup
              post :virtual_topup
              post :ban
              post :unban
            end
          end

          resources :customers, constraints: { id: /.*/ } do
            member do
              post :ban
              post :unban
              post :topup
              post :virtual_topup
              post :assign_gtag
              post :assign_ticket
              post :gtag_replacement
              get :refunds
              get :transactions
            end
          end

          resources :stations do
            resources :products
          end

          resources :refunds do
            put :complete, on: :member
          end

          resources :orders, except: %i[create update] do
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
          resources :operator_permissions, only: :index
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
          resources :tickets, only: [:index, :show], constraints: { id: /.*/ } do
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
end
