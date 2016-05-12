Rails.application.routes.draw do
  ## API
  ## ------------------------------
  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :events, only: :index do
        scope module: "events" do
          resources :transactions, only: :create
        end
      end
    end
  end

  namespace :admins do
    resources :events, only: [:index, :show, :new, :create, :edit, :update] do
      scope module: "events" do
        resources :missing_transactions, only: [:index]
        resources :credit_inconsistencies, only: [:index]

        resources :access_transactions, only: [:index, :show] do
          collection do
            get :search
          end
        end

        resources :credential_transactions, only: [:index, :show] do
          collection do
            get :search
          end
        end

        resources :credit_transactions, only: [:index, :show] do
          collection do
            get :search
          end
        end

        resources :money_transactions, only: [:index, :show] do
          collection do
            get :search
          end
        end

        resources :order_transactions, only: [:index, :show] do
          collection do
            get :search
          end
        end
        # resources :voucher_transactions, only: [:index, :show]
      end
    end
  end
end
