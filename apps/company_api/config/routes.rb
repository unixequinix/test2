Rails.application.routes.draw do
  ## Thirdparty API
  ## ------------------------------

  namespace :companies do
    namespace :api, defaults: { format: "json" } do
      namespace :v1 do
        resources :blacklists, path: "tickets/blacklist", only: [:index, :create, :destroy]
        resources :tickets, only: [:index, :show, :create, :update]
        resources :ticket_types, only: [:index, :show, :create, :update]
      end
    end
  end
end
