require "sidekiq/web"

Rails.application.routes.draw do
  root "admins/events#index"
  get "/admins", to: "admins/events#index", as: :admin_root
  get ":event_id", to: "events/events#show", as: :customer_root

  mount ActionCable.server => '/cable'

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
        resources :companies, except: :show do
          post :visibility, on: :member
        end
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
          post :visibility
          resources :station_items, only: [:create, :update, :destroy] do
            put :sort, on: :collection
            post :visibility
            get :find_product, on: :collection
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

      # Stripe
      post :mercadopago_purchase, to: "mercadopago#purchase"
      post :mercadopago_refund, to: "mercadopago#refund"

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

# == Route Map
#
#                                          Prefix Verb     URI Pattern                                                                                       Controller#Action
#                                            root GET      /                                                                                                 admins/events#index
#                                      admin_root GET      /admins(.:format)                                                                                 admins/events#index
#                                   customer_root GET      /:event_id(.:format)                                                                              events/events#show
#                                                          /cable                                                                                            #<ActionCable::Server::Base:0x007fc1b0e04d08 @mutex=#<Monitor:0x007fc1b0e04c90 @mon_owner=nil, @mon_count=0, @mon_mutex=#<Thread::Mutex:0x007fc1b0e04ba0>>, @pubsub=nil, @worker_pool=nil, @event_loop=nil, @remote_connections=nil>
#                                new_user_session GET      /users/sign_in(.:format)                                                                          admins/sessions#new
#                                    user_session POST     /users/sign_in(.:format)                                                                          admins/sessions#create
#                            destroy_user_session DELETE   /users/sign_out(.:format)                                                                         admins/sessions#destroy
#                                           users GET      /users(.:format)                                                                                  users#index
#                                                 POST     /users(.:format)                                                                                  users#create
#                                        new_user GET      /users/new(.:format)                                                                              users#new
#                                       edit_user GET      /users/:id/edit(.:format)                                                                         users#edit
#                                            user GET      /users/:id(.:format)                                                                              users#show
#                                                 PATCH    /users/:id(.:format)                                                                              users#update
#                                                 PUT      /users/:id(.:format)                                                                              users#update
#                                                 DELETE   /users/:id(.:format)                                                                              users#destroy
#                                  admins_devices GET      /admins/devices(.:format)                                                                         admins/devices#index
#                              edit_admins_device GET      /admins/devices/:id/edit(.:format)                                                                admins/devices#edit
#                                   admins_device GET      /admins/devices/:id(.:format)                                                                     admins/devices#show
#                                                 PATCH    /admins/devices/:id(.:format)                                                                     admins/devices#update
#                                                 PUT      /admins/devices/:id(.:format)                                                                     admins/devices#update
#                                                 DELETE   /admins/devices/:id(.:format)                                                                     admins/devices#destroy
#                          admins_eventbrite_auth GET      /admins/eventbrite/auth(.:format)                                                                 admins/eventbrite#auth
#                            change_admins_locale GET      /admins/locale/:id/change(.:format)                                                               admins/locale#change
#                             admins_locale_index GET      /admins/locale(.:format)                                                                          admins/locale#index
#                                                 POST     /admins/locale(.:format)                                                                          admins/locale#create
#                               new_admins_locale GET      /admins/locale/new(.:format)                                                                      admins/locale#new
#                              edit_admins_locale GET      /admins/locale/:id/edit(.:format)                                                                 admins/locale#edit
#                                   admins_locale GET      /admins/locale/:id(.:format)                                                                      admins/locale#show
#                                                 PATCH    /admins/locale/:id(.:format)                                                                      admins/locale#update
#                                                 PUT      /admins/locale/:id(.:format)                                                                      admins/locale#update
#                                                 DELETE   /admins/locale/:id(.:format)                                                                      admins/locale#destroy
#                      sample_event_admins_events GET      /admins/events/sample_event(.:format)                                                             admins/events#sample_event
#                   edit_event_style_admins_event GET      /admins/events/:id/edit_event_style(.:format)                                                     admins/events#edit_event_style
#                    device_settings_admins_event GET      /admins/events/:id/device_settings(.:format)                                                      admins/events#device_settings
#                          remove_db_admins_event DELETE   /admins/events/:id/remove_db(.:format)                                                            admins/events#remove_db
#                              stats_admins_event GET      /admins/events/:id/stats(.:format)                                                                admins/events#stats
#                             launch_admins_event GET      /admins/events/:id/launch(.:format)                                                               admins/events#launch
#                              close_admins_event GET      /admins/events/:id/close(.:format)                                                                admins/events#close
#                        remove_logo_admins_event POST     /admins/events/:id/remove_logo(.:format)                                                          admins/events#remove_logo
#                  remove_background_admins_event POST     /admins/events/:id/remove_background(.:format)                                                    admins/events#remove_background
#                       create_admin_admins_event GET      /admins/events/:id/create_admin(.:format)                                                         admins/events#create_admin
#            create_customer_support_admins_event GET      /admins/events/:id/create_customer_support(.:format)                                              admins/events#create_customer_support
#                            admins_event_refunds GET      /admins/events/:event_id/refunds(.:format)                                                        admins/events/refunds#index
#                             admins_event_refund GET      /admins/events/:event_id/refunds/:id(.:format)                                                    admins/events/refunds#show
#                             admins_event_orders GET      /admins/events/:event_id/orders(.:format)                                                         admins/events/orders#index
#                              admins_event_order GET      /admins/events/:event_id/orders/:id(.:format)                                                     admins/events/orders#show
#                    admins_event_gtag_assignment DELETE   /admins/events/:event_id/gtag_assignments/:id(.:format)                                           admins/events/gtag_assignments#destroy
#                       admins_event_ticket_types GET      /admins/events/:event_id/ticket_types(.:format)                                                   admins/events/ticket_types#index
#                                                 POST     /admins/events/:event_id/ticket_types(.:format)                                                   admins/events/ticket_types#create
#                    new_admins_event_ticket_type GET      /admins/events/:event_id/ticket_types/new(.:format)                                               admins/events/ticket_types#new
#                   edit_admins_event_ticket_type GET      /admins/events/:event_id/ticket_types/:id/edit(.:format)                                          admins/events/ticket_types#edit
#                        admins_event_ticket_type PATCH    /admins/events/:event_id/ticket_types/:id(.:format)                                               admins/events/ticket_types#update
#                                                 PUT      /admins/events/:event_id/ticket_types/:id(.:format)                                               admins/events/ticket_types#update
#                                                 DELETE   /admins/events/:event_id/ticket_types/:id(.:format)                                               admins/events/ticket_types#destroy
#                            admins_event_devices GET      /admins/events/:event_id/devices(.:format)                                                        admins/events/devices#index
#                     admins_event_asset_trackers GET      /admins/events/:event_id/asset_trackers(.:format)                                                 admins/events/asset_trackers#index
#                                                 POST     /admins/events/:event_id/asset_trackers(.:format)                                                 admins/events/asset_trackers#create
#                  new_admins_event_asset_tracker GET      /admins/events/:event_id/asset_trackers/new(.:format)                                             admins/events/asset_trackers#new
#                 edit_admins_event_asset_tracker GET      /admins/events/:event_id/asset_trackers/:id/edit(.:format)                                        admins/events/asset_trackers#edit
#                      admins_event_asset_tracker GET      /admins/events/:event_id/asset_trackers/:id(.:format)                                             admins/events/asset_trackers#show
#                                                 PATCH    /admins/events/:event_id/asset_trackers/:id(.:format)                                             admins/events/asset_trackers#update
#                                                 PUT      /admins/events/:event_id/asset_trackers/:id(.:format)                                             admins/events/asset_trackers#update
#                                                 DELETE   /admins/events/:event_id/asset_trackers/:id(.:format)                                             admins/events/asset_trackers#destroy
#                            admins_event_credits GET      /admins/events/:event_id/credits(.:format)                                                        admins/events/credits#index
#                        edit_admins_event_credit GET      /admins/events/:event_id/credits/:id/edit(.:format)                                               admins/events/credits#edit
#                             admins_event_credit GET      /admins/events/:event_id/credits/:id(.:format)                                                    admins/events/credits#show
#                                                 PATCH    /admins/events/:event_id/credits/:id(.:format)                                                    admins/events/credits#update
#                                                 PUT      /admins/events/:event_id/credits/:id(.:format)                                                    admins/events/credits#update
#                                                 DELETE   /admins/events/:event_id/credits/:id(.:format)                                                    admins/events/credits#destroy
#                       admins_event_catalog_item PATCH    /admins/events/:event_id/catalog_items/:id(.:format)                                              admins/events/catalog_items#update
#                                                 PUT      /admins/events/:event_id/catalog_items/:id(.:format)                                              admins/events/catalog_items#update
#                           admins_event_accesses GET      /admins/events/:event_id/accesses(.:format)                                                       admins/events/accesses#index
#                                                 POST     /admins/events/:event_id/accesses(.:format)                                                       admins/events/accesses#create
#                         new_admins_event_access GET      /admins/events/:event_id/accesses/new(.:format)                                                   admins/events/accesses#new
#                        edit_admins_event_access GET      /admins/events/:event_id/accesses/:id/edit(.:format)                                              admins/events/accesses#edit
#                             admins_event_access GET      /admins/events/:event_id/accesses/:id(.:format)                                                   admins/events/accesses#show
#                                                 PATCH    /admins/events/:event_id/accesses/:id(.:format)                                                   admins/events/accesses#update
#                                                 PUT      /admins/events/:event_id/accesses/:id(.:format)                                                   admins/events/accesses#update
#                                                 DELETE   /admins/events/:event_id/accesses/:id(.:format)                                                   admins/events/accesses#destroy
#                              admins_event_packs GET      /admins/events/:event_id/packs(.:format)                                                          admins/events/packs#index
#                                                 POST     /admins/events/:event_id/packs(.:format)                                                          admins/events/packs#create
#                           new_admins_event_pack GET      /admins/events/:event_id/packs/new(.:format)                                                      admins/events/packs#new
#                          edit_admins_event_pack GET      /admins/events/:event_id/packs/:id/edit(.:format)                                                 admins/events/packs#edit
#                               admins_event_pack GET      /admins/events/:event_id/packs/:id(.:format)                                                      admins/events/packs#show
#                                                 PATCH    /admins/events/:event_id/packs/:id(.:format)                                                      admins/events/packs#update
#                                                 PUT      /admins/events/:event_id/packs/:id(.:format)                                                      admins/events/packs#update
#                                                 DELETE   /admins/events/:event_id/packs/:id(.:format)                                                      admins/events/packs#destroy
#                  admins_event_ticket_assignment DELETE   /admins/events/:event_id/ticket_assignments/:id(.:format)                                         admins/events/ticket_assignments#destroy
#                 visibility_admins_event_company POST     /admins/events/:event_id/companies/:id/visibility(.:format)                                       admins/events/companies#visibility
#                          admins_event_companies GET      /admins/events/:event_id/companies(.:format)                                                      admins/events/companies#index
#                                                 POST     /admins/events/:event_id/companies(.:format)                                                      admins/events/companies#create
#                        new_admins_event_company GET      /admins/events/:event_id/companies/new(.:format)                                                  admins/events/companies#new
#                       edit_admins_event_company GET      /admins/events/:event_id/companies/:id/edit(.:format)                                             admins/events/companies#edit
#                            admins_event_company PATCH    /admins/events/:event_id/companies/:id(.:format)                                                  admins/events/companies#update
#                                                 PUT      /admins/events/:event_id/companies/:id(.:format)                                                  admins/events/companies#update
#                                                 DELETE   /admins/events/:event_id/companies/:id(.:format)                                                  admins/events/companies#destroy
#                              admins_event_users GET      /admins/events/:event_id/users(.:format)                                                          admins/events/users#index
#                                                 POST     /admins/events/:event_id/users(.:format)                                                          admins/events/users#create
#                           new_admins_event_user GET      /admins/events/:event_id/users/new(.:format)                                                      admins/events/users#new
#                          edit_admins_event_user GET      /admins/events/:event_id/users/:id/edit(.:format)                                                 admins/events/users#edit
#                               admins_event_user GET      /admins/events/:event_id/users/:id(.:format)                                                      admins/events/users#show
#                                                 PATCH    /admins/events/:event_id/users/:id(.:format)                                                      admins/events/users#update
#                                                 PUT      /admins/events/:event_id/users/:id(.:format)                                                      admins/events/users#update
#                                                 DELETE   /admins/events/:event_id/users/:id(.:format)                                                      admins/events/users#destroy
#                         admins_event_eventbrite GET      /admins/events/:event_id/eventbrite(.:format)                                                     admins/events/eventbrite#index
#          admins_event_eventbrite_import_tickets GET      /admins/events/:event_id/eventbrite/import_tickets(.:format)                                      admins/events/eventbrite#import_tickets
#              admins_event_eventbrite_disconnect GET      /admins/events/:event_id/eventbrite/disconnect(.:format)                                          admins/events/eventbrite#disconnect
#                 admins_event_eventbrite_connect GET      /admins/events/:event_id/eventbrite/connect/:eb_event_id(.:format)                                admins/events/eventbrite#connect
#                admins_event_eventbrite_webhooks POST     /admins/events/:event_id/eventbrite/webhooks(.:format)                                            admins/events/eventbrite#webhooks
#            missing_admins_event_inconsistencies GET      /admins/events/:event_id/inconsistencies/missing(.:format)                                        admins/events/inconsistencies#missing
#               real_admins_event_inconsistencies GET      /admins/events/:event_id/inconsistencies/real(.:format)                                           admins/events/inconsistencies#real
#         resolvable_admins_event_inconsistencies GET      /admins/events/:event_id/inconsistencies/resolvable(.:format)                                     admins/events/inconsistencies#resolvable
#                    admins_event_inconsistencies GET      /admins/events/:event_id/inconsistencies(.:format)                                                admins/events/inconsistencies#index
#                                                 POST     /admins/events/:event_id/inconsistencies(.:format)                                                admins/events/inconsistencies#create
#                  new_admins_event_inconsistency GET      /admins/events/:event_id/inconsistencies/new(.:format)                                            admins/events/inconsistencies#new
#                 edit_admins_event_inconsistency GET      /admins/events/:event_id/inconsistencies/:id/edit(.:format)                                       admins/events/inconsistencies#edit
#                      admins_event_inconsistency GET      /admins/events/:event_id/inconsistencies/:id(.:format)                                            admins/events/inconsistencies#show
#                                                 PATCH    /admins/events/:event_id/inconsistencies/:id(.:format)                                            admins/events/inconsistencies#update
#                                                 PUT      /admins/events/:event_id/inconsistencies/:id(.:format)                                            admins/events/inconsistencies#update
#                                                 DELETE   /admins/events/:event_id/inconsistencies/:id(.:format)                                            admins/events/inconsistencies#destroy
#                search_admins_event_transactions POST     /admins/events/:event_id/transactions/search(.:format)                                            admins/events/transactions#search
#                    fix_admins_event_transaction GET      /admins/events/:event_id/transactions/:id/fix(.:format)                                           admins/events/transactions#fix
#                       admins_event_transactions GET      /admins/events/:event_id/transactions(.:format)                                                   admins/events/transactions#index
#                        admins_event_transaction GET      /admins/events/:event_id/transactions/:id(.:format)                                               admins/events/transactions#show
#                                                 PATCH    /admins/events/:event_id/transactions/:id(.:format)                                               admins/events/transactions#update
#                                                 PUT      /admins/events/:event_id/transactions/:id(.:format)                                               admins/events/transactions#update
#              topup_admins_event_payment_gateway POST     /admins/events/:event_id/payment_gateways/:id/topup(.:format)                                     admins/events/payment_gateways#topup
#             refund_admins_event_payment_gateway POST     /admins/events/:event_id/payment_gateways/:id/refund(.:format)                                    admins/events/payment_gateways#refund
#                   admins_event_payment_gateways GET      /admins/events/:event_id/payment_gateways(.:format)                                               admins/events/payment_gateways#index
#                                                 POST     /admins/events/:event_id/payment_gateways(.:format)                                               admins/events/payment_gateways#create
#                new_admins_event_payment_gateway GET      /admins/events/:event_id/payment_gateways/new(.:format)                                           admins/events/payment_gateways#new
#               edit_admins_event_payment_gateway GET      /admins/events/:event_id/payment_gateways/:id/edit(.:format)                                      admins/events/payment_gateways#edit
#                    admins_event_payment_gateway PATCH    /admins/events/:event_id/payment_gateways/:id(.:format)                                           admins/events/payment_gateways#update
#                                                 PUT      /admins/events/:event_id/payment_gateways/:id(.:format)                                           admins/events/payment_gateways#update
#                                                 DELETE   /admins/events/:event_id/payment_gateways/:id(.:format)                                           admins/events/payment_gateways#destroy
#                 admins_event_ticket_assignments POST     /admins/events/:event_id/customers/:id/ticket_assignments(.:format)                               admins/events/ticket_assignments#create
#              new_admins_event_ticket_assignment GET      /admins/events/:event_id/customers/:id/ticket_assignments/new(.:format)                           admins/events/ticket_assignments#new
#                   admins_event_gtag_assignments POST     /admins/events/:event_id/customers/:id/gtag_assignments(.:format)                                 admins/events/gtag_assignments#create
#                new_admins_event_gtag_assignment GET      /admins/events/:event_id/customers/:id/gtag_assignments/new(.:format)                             admins/events/gtag_assignments#new
#     download_transactions_admins_event_customer GET      /admins/events/:event_id/customers/:id/download_transactions(.:format)                            admins/events/customers#download_transactions
#            reset_password_admins_event_customer GET      /admins/events/:event_id/customers/:id/reset_password(.:format)                                   admins/events/customers#reset_password
#                          admins_event_customers GET      /admins/events/:event_id/customers(.:format)                                                      admins/events/customers#index
#                           admins_event_customer GET      /admins/events/:event_id/customers/:id(.:format)                                                  admins/events/customers#show
#           recalculate_balance_admins_event_gtag GET      /admins/events/:event_id/gtags/:id/recalculate_balance(.:format)                                  admins/events/gtags#recalculate_balance
#                           ban_admins_event_gtag GET      /admins/events/:event_id/gtags/:id/ban(.:format)                                                  admins/events/gtags#ban
#            solve_inconsistent_admins_event_gtag GET      /admins/events/:event_id/gtags/:id/solve_inconsistent(.:format)                                   admins/events/gtags#solve_inconsistent
#                         unban_admins_event_gtag GET      /admins/events/:event_id/gtags/:id/unban(.:format)                                                admins/events/gtags#unban
#                   sample_csv_admins_event_gtags GET      /admins/events/:event_id/gtags/sample_csv(.:format)                                               admins/events/gtags#sample_csv
#                       import_admins_event_gtags POST     /admins/events/:event_id/gtags/import(.:format)                                                   admins/events/gtags#import
#                              admins_event_gtags GET      /admins/events/:event_id/gtags(.:format)                                                          admins/events/gtags#index
#                                                 POST     /admins/events/:event_id/gtags(.:format)                                                          admins/events/gtags#create
#                           new_admins_event_gtag GET      /admins/events/:event_id/gtags/new(.:format)                                                      admins/events/gtags#new
#                          edit_admins_event_gtag GET      /admins/events/:event_id/gtags/:id/edit(.:format)                                                 admins/events/gtags#edit
#                               admins_event_gtag GET      /admins/events/:event_id/gtags/:id(.:format)                                                      admins/events/gtags#show
#                                                 PATCH    /admins/events/:event_id/gtags/:id(.:format)                                                      admins/events/gtags#update
#                                                 PUT      /admins/events/:event_id/gtags/:id(.:format)                                                      admins/events/gtags#update
#                                                 DELETE   /admins/events/:event_id/gtags/:id(.:format)                                                      admins/events/gtags#destroy
#                         ban_admins_event_ticket GET      /admins/events/:event_id/tickets/:id/ban(.:format)                                                admins/events/tickets#ban
#                       unban_admins_event_ticket GET      /admins/events/:event_id/tickets/:id/unban(.:format)                                              admins/events/tickets#unban
#                 sample_csv_admins_event_tickets GET      /admins/events/:event_id/tickets/sample_csv(.:format)                                             admins/events/tickets#sample_csv
#                     import_admins_event_tickets POST     /admins/events/:event_id/tickets/import(.:format)                                                 admins/events/tickets#import
#                            admins_event_tickets GET      /admins/events/:event_id/tickets(.:format)                                                        admins/events/tickets#index
#                                                 POST     /admins/events/:event_id/tickets(.:format)                                                        admins/events/tickets#create
#                         new_admins_event_ticket GET      /admins/events/:event_id/tickets/new(.:format)                                                    admins/events/tickets#new
#                        edit_admins_event_ticket GET      /admins/events/:event_id/tickets/:id/edit(.:format)                                               admins/events/tickets#edit
#                             admins_event_ticket GET      /admins/events/:event_id/tickets/:id(.:format)                                                    admins/events/tickets#show
#                                                 PATCH    /admins/events/:event_id/tickets/:id(.:format)                                                    admins/events/tickets#update
#                                                 PUT      /admins/events/:event_id/tickets/:id(.:format)                                                    admins/events/tickets#update
#                                                 DELETE   /admins/events/:event_id/tickets/:id(.:format)                                                    admins/events/tickets#destroy
#                    import_admins_event_products POST     /admins/events/:event_id/products/import(.:format)                                                admins/events/products#import
#                sample_csv_admins_event_products GET      /admins/events/:event_id/products/sample_csv(.:format)                                            admins/events/products#sample_csv
#                           admins_event_products GET      /admins/events/:event_id/products(.:format)                                                       admins/events/products#index
#                                                 POST     /admins/events/:event_id/products(.:format)                                                       admins/events/products#create
#                        new_admins_event_product GET      /admins/events/:event_id/products/new(.:format)                                                   admins/events/products#new
#                       edit_admins_event_product GET      /admins/events/:event_id/products/:id/edit(.:format)                                              admins/events/products#edit
#                            admins_event_product GET      /admins/events/:event_id/products/:id(.:format)                                                   admins/events/products#show
#                                                 PATCH    /admins/events/:event_id/products/:id(.:format)                                                   admins/events/products#update
#                                                 PUT      /admins/events/:event_id/products/:id(.:format)                                                   admins/events/products#update
#                                                 DELETE   /admins/events/:event_id/products/:id(.:format)                                                   admins/events/products#destroy
#                      admins_event_station_clone POST     /admins/events/:event_id/stations/:station_id/clone(.:format)                                     admins/events/stations#clone
#                 admins_event_station_visibility POST     /admins/events/:event_id/stations/:station_id/visibility(.:format)                                admins/events/stations#visibility
#         sort_admins_event_station_station_items PUT      /admins/events/:event_id/stations/:station_id/station_items/sort(.:format)                        admins/events/station_items#sort
#    admins_event_station_station_item_visibility POST     /admins/events/:event_id/stations/:station_id/station_items/:station_item_id/visibility(.:format) admins/events/station_items#visibility
# find_product_admins_event_station_station_items GET      /admins/events/:event_id/stations/:station_id/station_items/find_product(.:format)                admins/events/station_items#find_product
#              admins_event_station_station_items POST     /admins/events/:event_id/stations/:station_id/station_items(.:format)                             admins/events/station_items#create
#               admins_event_station_station_item PATCH    /admins/events/:event_id/stations/:station_id/station_items/:id(.:format)                         admins/events/station_items#update
#                                                 PUT      /admins/events/:event_id/stations/:station_id/station_items/:id(.:format)                         admins/events/station_items#update
#                                                 DELETE   /admins/events/:event_id/stations/:station_id/station_items/:id(.:format)                         admins/events/station_items#destroy
#                           admins_event_stations GET      /admins/events/:event_id/stations(.:format)                                                       admins/events/stations#index
#                                                 POST     /admins/events/:event_id/stations(.:format)                                                       admins/events/stations#create
#                        new_admins_event_station GET      /admins/events/:event_id/stations/new(.:format)                                                   admins/events/stations#new
#                       edit_admins_event_station GET      /admins/events/:event_id/stations/:id/edit(.:format)                                              admins/events/stations#edit
#                            admins_event_station GET      /admins/events/:event_id/stations/:id(.:format)                                                   admins/events/stations#show
#                                                 PATCH    /admins/events/:event_id/stations/:id(.:format)                                                   admins/events/stations#update
#                                                 PUT      /admins/events/:event_id/stations/:id(.:format)                                                   admins/events/stations#update
#                                                 DELETE   /admins/events/:event_id/stations/:id(.:format)                                                   admins/events/stations#destroy
#             admins_event_ticket_type_visibility POST     /admins/events/:event_id/ticket_types/:ticket_type_id/visibility(.:format)                        admins/events/ticket_types#visibility
#                                                 GET      /admins/events/:event_id/ticket_types(.:format)                                                   admins/events/ticket_types#index
#                                                 POST     /admins/events/:event_id/ticket_types(.:format)                                                   admins/events/ticket_types#create
#                                                 GET      /admins/events/:event_id/ticket_types/new(.:format)                                               admins/events/ticket_types#new
#                                                 GET      /admins/events/:event_id/ticket_types/:id/edit(.:format)                                          admins/events/ticket_types#edit
#                                                 PATCH    /admins/events/:event_id/ticket_types/:id(.:format)                                               admins/events/ticket_types#update
#                                                 PUT      /admins/events/:event_id/ticket_types/:id(.:format)                                               admins/events/ticket_types#update
#                                                 DELETE   /admins/events/:event_id/ticket_types/:id(.:format)                                               admins/events/ticket_types#destroy
#                                   admins_events GET      /admins/events(.:format)                                                                          admins/events#index
#                                                 POST     /admins/events(.:format)                                                                          admins/events#create
#                                new_admins_event GET      /admins/events/new(.:format)                                                                      admins/events#new
#                               edit_admins_event GET      /admins/events/:id/edit(.:format)                                                                 admins/events#edit
#                                    admins_event GET      /admins/events/:id(.:format)                                                                      admins/events#show
#                                                 PATCH    /admins/events/:id(.:format)                                                                      admins/events#update
#                                                 PUT      /admins/events/:id(.:format)                                                                      admins/events#update
#                                                 DELETE   /admins/events/:id(.:format)                                                                      admins/events#destroy
#                              admins_sidekiq_web          /admins/sidekiq                                                                                   Sidekiq::Web
#            customer_facebook_omniauth_authorize GET|POST /customers/auth/facebook(.:format)                                                                events/omniauth_callbacks#passthru
#             customer_facebook_omniauth_callback GET|POST /customers/auth/facebook/callback(.:format)                                                       events/omniauth_callbacks#facebook
#       customer_google_oauth2_omniauth_authorize GET|POST /customers/auth/google_oauth2(.:format)                                                           events/omniauth_callbacks#passthru
#        customer_google_oauth2_omniauth_callback GET|POST /customers/auth/google_oauth2/callback(.:format)                                                  events/omniauth_callbacks#google_oauth2
#                      new_customer_event_session GET      /customers/:event_id/sign_in(.:format)                                                            events/sessions#new
#                          customer_event_session POST     /customers/:event_id/sign_in(.:format)                                                            events/sessions#create
#                  destroy_customer_event_session DELETE   /customers/:event_id/sign_out(.:format)                                                           events/sessions#destroy
#                     new_customer_event_password GET      /customers/:event_id/password/new(.:format)                                                       events/passwords#new
#                    edit_customer_event_password GET      /customers/:event_id/password/edit(.:format)                                                      events/passwords#edit
#                         customer_event_password PATCH    /customers/:event_id/password(.:format)                                                           events/passwords#update
#                                                 PUT      /customers/:event_id/password(.:format)                                                           events/passwords#update
#                                                 POST     /customers/:event_id/password(.:format)                                                           events/passwords#create
#              cancel_customer_event_registration GET      /customers/:event_id/cancel(.:format)                                                             events/registrations#cancel
#                 new_customer_event_registration GET      /customers/:event_id/sign_up(.:format)                                                            events/registrations#new
#                edit_customer_event_registration GET      /customers/:event_id/edit(.:format)                                                               events/registrations#edit
#                     customer_event_registration PATCH    /customers/:event_id(.:format)                                                                    events/registrations#update
#                                                 PUT      /customers/:event_id(.:format)                                                                    events/registrations#update
#                                                 DELETE   /customers/:event_id(.:format)                                                                    events/registrations#destroy
#                                                 POST     /customers/:event_id(.:format)                                                                    events/registrations#create
#                                     event_login GET      /:event_id/login(.:format)                                                                        events/sessions#new
#                                                 POST     /:event_id/login(.:format)                                                                        events/sessions#create
#                                    event_logout DELETE   /:event_id/logout(.:format)                                                                       events/sessions#destroy
#                                  event_register GET      /:event_id/register(.:format)                                                                     events/registrations#new
#                                   event_account GET      /:event_id/account(.:format)                                                                      events/registrations#edit
#                                                 POST     /:event_id/register(.:format)                                                                     events/registrations#create
#                                                 PATCH    /:event_id/register(.:format)                                                                     events/registrations#update
#                          event_recover_password GET      /:event_id/recover_password(.:format)                                                             events/passwords#new
#                                                 POST     /:event_id/recover_password(.:format)                                                             events/passwords#create
#                             event_edit_password GET      /:event_id/edit_password(.:format)                                                                events/passwords#edit
#                                                 PATCH    /:event_id/edit_password(.:format)                                                                events/passwords#update
#                                    event_signin GET      /:event_id/signin(.:format)                                                                       events/registrations#new
#                                                 GET      /:event_id/login(.:format)                                                                        events/sessions#new
#                                                 DELETE   /:event_id/logout(.:format)                                                                       events/sessions#destroy
#                             change_event_locale GET      /:event_id/locale/:id/change(.:format)                                                            events/locale#change
#                              event_locale_index GET      /:event_id/locale(.:format)                                                                       events/locale#index
#                                                 POST     /:event_id/locale(.:format)                                                                       events/locale#create
#                                new_event_locale GET      /:event_id/locale/new(.:format)                                                                   events/locale#new
#                               edit_event_locale GET      /:event_id/locale/:id/edit(.:format)                                                              events/locale#edit
#                                    event_locale GET      /:event_id/locale/:id(.:format)                                                                   events/locale#show
#                                                 PATCH    /:event_id/locale/:id(.:format)                                                                   events/locale#update
#                                                 PUT      /:event_id/locale/:id(.:format)                                                                   events/locale#update
#                                                 DELETE   /:event_id/locale/:id(.:format)                                                                   events/locale#destroy
#                        event_ticket_assignments POST     /:event_id/ticket_assignments(.:format)                                                           events/ticket_assignments#create
#                     new_event_ticket_assignment GET      /:event_id/ticket_assignments/new(.:format)                                                       events/ticket_assignments#new
#                         event_ticket_assignment DELETE   /:event_id/ticket_assignments/:id(.:format)                                                       events/ticket_assignments#destroy
#                          event_gtag_assignments POST     /:event_id/gtag_assignments(.:format)                                                             events/gtag_assignments#create
#                       new_event_gtag_assignment GET      /:event_id/gtag_assignments/new(.:format)                                                         events/gtag_assignments#new
#                           event_gtag_assignment DELETE   /:event_id/gtag_assignments/:id(.:format)                                                         events/gtag_assignments#destroy
#                                    event_ticket GET      /:event_id/tickets/:id(.:format)                                                                  events/tickets#show
#                                    event_orders GET      /:event_id/orders(.:format)                                                                       events/orders#index {:expect=>:destroy}
#                                                 POST     /:event_id/orders(.:format)                                                                       events/orders#create {:expect=>:destroy}
#                                 new_event_order GET      /:event_id/orders/new(.:format)                                                                   events/orders#new {:expect=>:destroy}
#                                edit_event_order GET      /:event_id/orders/:id/edit(.:format)                                                              events/orders#edit {:expect=>:destroy}
#                                     event_order GET      /:event_id/orders/:id(.:format)                                                                   events/orders#show {:expect=>:destroy}
#                                                 PATCH    /:event_id/orders/:id(.:format)                                                                   events/orders#update {:expect=>:destroy}
#                                                 PUT      /:event_id/orders/:id(.:format)                                                                   events/orders#update {:expect=>:destroy}
#                                                 DELETE   /:event_id/orders/:id(.:format)                                                                   events/orders#destroy {:expect=>:destroy}
#                           event_credits_history GET      /:event_id/credits_history(.:format)                                                              events/credits_histories#history
#                            event_privacy_policy GET      /:event_id/privacy_policy(.:format)                                                               events/static_pages#privacy_policy
#                              event_terms_of_use GET      /:event_id/terms_of_use(.:format)                                                                 events/static_pages#terms_of_use
#                     event_paypal_setup_purchase GET      /:event_id/paypal_setup_purchase(.:format)                                                        events/paypal#setup_purchase
#                           event_paypal_purchase GET      /:event_id/paypal_purchase(.:format)                                                              events/paypal#purchase
#                             event_paypal_refund POST     /:event_id/paypal_refund(.:format)                                                                events/paypal#refund
#                           event_redsys_purchase POST     /:event_id/redsys_purchase(.:format)                                                              events/redsys#purchase
#                             event_redsys_refund POST     /:event_id/redsys_refund(.:format)                                                                events/redsys#refund
#                           event_stripe_purchase POST     /:event_id/stripe_purchase(.:format)                                                              events/stripe#purchase
#                             event_stripe_refund POST     /:event_id/stripe_refund(.:format)                                                                events/stripe#refund
#                      event_mercadopago_purchase POST     /:event_id/mercadopago_purchase(.:format)                                                         events/mercadopago#purchase
#                        event_mercadopago_refund POST     /:event_id/mercadopago_refund(.:format)                                                           events/mercadopago#refund
#                         event_wirecard_purchase POST     /:event_id/wirecard_purchase(.:format)                                                            events/wirecard#purchase
#                           event_wirecard_refund POST     /:event_id/wirecard_refund(.:format)                                                              events/wirecard#refund
#                                   event_refunds GET      /:event_id/refunds(.:format)                                                                      events/refunds#index
#                                                 POST     /:event_id/refunds(.:format)                                                                      events/refunds#create
#                                new_event_refund GET      /:event_id/refunds/new(.:format)                                                                  events/refunds#new
#                               edit_event_refund GET      /:event_id/refunds/:id/edit(.:format)                                                             events/refunds#edit
#                                    event_refund GET      /:event_id/refunds/:id(.:format)                                                                  events/refunds#show
#                                                 PATCH    /:event_id/refunds/:id(.:format)                                                                  events/refunds#update
#                                                 PUT      /:event_id/refunds/:id(.:format)                                                                  events/refunds#update
#                                                 DELETE   /:event_id/refunds/:id(.:format)                                                                  events/refunds#destroy
#                                           event GET      /:id(.:format)                                                                                    events/events#show
#                                  api_v1_devices POST     /api/v1/devices(.:format)                                                                         api/v1/devices#create {:format=>"json"}
#                           api_v1_event_database GET      /api/v1/events/:event_id/database(.:format)                                                       api/v1/events/databases#show {:format=>"json"}
#                                                 POST     /api/v1/events/:event_id/database(.:format)                                                       api/v1/events/databases#create {:format=>"json"}
#                           api_v1_event_accesses GET      /api/v1/events/:event_id/accesses(.:format)                                                       api/v1/events/accesses#index {:format=>"json"}
#                       api_v1_event_auto_top_ups POST     /api/v1/events/:event_id/auto_top_ups(.:format)                                                   api/v1/events/auto_top_ups#create {:format=>"json"}
#                            api_v1_event_backups POST     /api/v1/events/:event_id/backups(.:format)                                                        api/v1/events/backups#create {:format=>"json"}
#                       api_v1_event_ticket_types GET      /api/v1/events/:event_id/ticket_types(.:format)                                                   api/v1/events/ticket_types#index {:format=>"json"}
#                            api_v1_event_credits GET      /api/v1/events/:event_id/credits(.:format)                                                        api/v1/events/credits#index {:format=>"json"}
#                          api_v1_event_customers GET      /api/v1/events/:event_id/customers(.:format)                                                      api/v1/events/customers#index {:format=>"json"}
#                           api_v1_event_customer GET      /api/v1/events/:event_id/customers/:id(.:format)                                                  api/v1/events/customers#show {:format=>"json"}
#                             api_v1_event_orders GET      /api/v1/events/:event_id/orders(.:format)                                                         api/v1/events/orders#index {:format=>"json"}
#                              api_v1_event_packs GET      /api/v1/events/:event_id/packs(.:format)                                                          api/v1/events/packs#index {:format=>"json"}
#                         api_v1_event_parameters GET      /api/v1/events/:event_id/parameters(.:format)                                                     api/v1/events/parameters#index {:format=>"json"}
#                           api_v1_event_products GET      /api/v1/events/:event_id/products(.:format)                                                       api/v1/events/products#index {:format=>"json"}
#                           api_v1_event_stations GET      /api/v1/events/:event_id/stations(.:format)                                                       api/v1/events/stations#index {:format=>"json"}
#                       api_v1_event_transactions POST     /api/v1/events/:event_id/transactions(.:format)                                                   api/v1/events/transactions#create {:format=>"json"}
#                api_v1_event_device_transactions POST     /api/v1/events/:event_id/device_transactions(.:format)                                            api/v1/events/device_transactions#create {:format=>"json"}
#                         api_v1_event_user_flags GET      /api/v1/events/:event_id/user_flags(.:format)                                                     api/v1/events/user_flags#index {:format=>"json"}
#                     banned_api_v1_event_tickets GET      /api/v1/events/:event_id/tickets/banned(.:format)                                                 api/v1/events/tickets#banned {:format=>"json"}
#                            api_v1_event_tickets GET      /api/v1/events/:event_id/tickets(.:format)                                                        api/v1/events/tickets#index {:format=>"json"}
#                             api_v1_event_ticket GET      /api/v1/events/:event_id/tickets/:id(.:format)                                                    api/v1/events/tickets#show {:format=>"json"}
#                       banned_api_v1_event_gtags GET      /api/v1/events/:event_id/gtags/banned(.:format)                                                   api/v1/events/gtags#banned {:format=>"json"}
#                              api_v1_event_gtags GET      /api/v1/events/:event_id/gtags(.:format)                                                          api/v1/events/gtags#index {:format=>"json"}
#                               api_v1_event_gtag GET      /api/v1/events/:event_id/gtags/:id(.:format)                                                      api/v1/events/gtags#show {:format=>"json"}
#                               api_v1_event_time GET      /api/v1/events/:event_id/time(.:format)                                                           api/v1/events/time#index {:format=>"json"}
#                                   api_v1_events GET      /api/v1/events(.:format)                                                                          api/v1/events#index {:format=>"json"}
#                 companies_api_v1_banned_tickets GET      /companies/api/v1/tickets/blacklist(.:format)                                                     companies/api/v1/banned_tickets#index {:format=>"json"}
#                                                 POST     /companies/api/v1/tickets/blacklist(.:format)                                                     companies/api/v1/banned_tickets#create {:format=>"json"}
#                  companies_api_v1_banned_ticket DELETE   /companies/api/v1/tickets/blacklist/:id(.:format)                                                 companies/api/v1/banned_tickets#destroy {:format=>"json"}
#            bulk_upload_companies_api_v1_tickets POST     /companies/api/v1/tickets/bulk_upload(.:format)                                                   companies/api/v1/tickets#bulk_upload {:format=>"json"}
#                        companies_api_v1_tickets GET      /companies/api/v1/tickets(.:format)                                                               companies/api/v1/tickets#index {:format=>"json"}
#                                                 POST     /companies/api/v1/tickets(.:format)                                                               companies/api/v1/tickets#create {:format=>"json"}
#                         companies_api_v1_ticket GET      /companies/api/v1/tickets/:id(.:format)                                                           companies/api/v1/tickets#show {:format=>"json"}
#                                                 PATCH    /companies/api/v1/tickets/:id(.:format)                                                           companies/api/v1/tickets#update {:format=>"json"}
#                                                 PUT      /companies/api/v1/tickets/:id(.:format)                                                           companies/api/v1/tickets#update {:format=>"json"}
#                   companies_api_v1_ticket_types GET      /companies/api/v1/ticket_types(.:format)                                                          companies/api/v1/ticket_types#index {:format=>"json"}
#                                                 POST     /companies/api/v1/ticket_types(.:format)                                                          companies/api/v1/ticket_types#create {:format=>"json"}
#                    companies_api_v1_ticket_type GET      /companies/api/v1/ticket_types/:id(.:format)                                                      companies/api/v1/ticket_types#show {:format=>"json"}
#                                                 PATCH    /companies/api/v1/ticket_types/:id(.:format)                                                      companies/api/v1/ticket_types#update {:format=>"json"}
#                                                 PUT      /companies/api/v1/ticket_types/:id(.:format)                                                      companies/api/v1/ticket_types#update {:format=>"json"}
#                        companies_api_v1_balance GET      /companies/api/v1/balances/:id(.:format)                                                          companies/api/v1/balances#show {:format=>"json"}
#
