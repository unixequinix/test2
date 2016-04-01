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
        resources :access_transactions, only: [:index, :show]
        resources :credential_transactions, only: [:index, :show]
        # resources :credit_transactions, only: [:index, :show]
        # resources :money_transactions, only: [:index, :show]
        # resources :orders_transactions, only: [:index, :show]
        # resources :voucher_transactions, only: [:index, :show]
      end
    end
  end
end
