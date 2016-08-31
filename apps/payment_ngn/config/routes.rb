require "sidekiq/web"

Rails.application.routes.draw do
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
        resources :payment_settings, only: [:index, :new, :create, :edit, :update]
        resources :orders, except: [:new, :create, :edit, :update] do
          collection do
            get :search
          end
        end
        resources :payments, except: [:new, :create, :edit, :update] do
          collection do
            get :search
          end
        end
      end
    end
  end
end
