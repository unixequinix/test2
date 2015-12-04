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
        resources :refund_settings, only: [:index, :edit, :update] do
          collection do
            get :edit_messages
            patch :update_messages
            post :notify_customers
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
  end

  scope module: 'events' do
    resources :events, only: [:show], path: '/' do
      # TODO Check security in this action
      # resources :refunds, only: [:create], constraints: lambda{|request|request.env['HTTP_X_REAL_IP'].match(Rails.application.secrets.merchant_ip)}
      resources :refunds, only: [:create] do
        collection do
          get 'success'
          get 'error'
        end
      end
      resources :epg_claims, only: [:new, :create]
      resources :bank_account_claims, only: [:new, :create]
      resources :tipalti_claims, only: [:new, :create]
    end
  end
end



