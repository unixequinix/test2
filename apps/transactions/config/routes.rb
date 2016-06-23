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

        resources :transactions, only: [:index, :show, :update] do
          collection do
            get :search
          end
        end
      end
    end
  end
end
