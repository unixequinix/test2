require "admin_constraints"
require "sidekiq/web"

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
      scope module: "events" do
        resources :refund_settings, only: [:index, :edit, :update] do
          collection do
            get :edit_messages
            patch :update_messages
            post :notify_customers
            post :paypal_refund
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
end
