Rails.application.routes.draw do
  scope module: "events" do
    resources :events, only: [:show], path: "/" do
      devise_for :customers
      devise_scope :customer do
        get "/login", to: "sessions#new"
        post "/login", to: "sessions#create"
        delete "/logout", to: "sessions#destroy"
        get "/register", to: "registrations#new"
        get "/account", to: "registrations#edit"
        post "/register", to: "registrations#create"
        patch "/register", to: "registrations#update"
        get "/change_password", to: "registrations#change_password"
        patch "/change_password", to: "registrations#update_password"
        get "/recover_password", to: "passwords#new"
        post "/recover_password", to: "passwords#create"
        get "/edit_password", to: "passwords#edit"
        patch "/edit_password", to: "passwords#update"
      end

      resource :info
      resources :locale do
        member do
          get "change"
        end
      end
      get "signin", to: "registrations#new"
      get "login", to: "sessions#new"
      delete "logout", to: "sessions#destroy"
      resources :customers do
        collection do
          resource :registrations, only: [:new, :create, :edit, :update]
          resource :sessions, only: [:new, :create, :destroy]
          resource :passwords, only: [:new, :create, :edit, :update]
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
          # TODO: Check security in this action
          # resources :payments, only: [:create],
          # =>                   constraints: lambda{|request|
          # =>  request.env['HTTP_X_REAL_IP'].match(Rails.application.secrets.merchant_ip)}
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
      # TODO: Check security in this action
      # resources :refunds, only: [:create],
      # =>                  constraints: lambda{ |request|
      # =>  equest.env['HTTP_X_REAL_IP'].match(Rails.application.secrets.merchant_ip)}
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
  get ":event_id", to: "events/events#show", as: :customer_root
end
