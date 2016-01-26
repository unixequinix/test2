Rails.application.routes.draw do
  ## Thirdparty API
  ## ------------------------------

  namespace :companies do
    namespace :api, defaults: { format: "json" } do
      namespace :v1 do
        resources :banned_tickets, path: "tickets/banned", only: [:index, :create, :destroy]
        resources :banned_gtags, path: "gtags/banned", only: [:index, :create, :destroy]
        resources :tickets, only: [:index, :show, :create, :update]
        resources :ticket_types, only: [:index, :show, :create, :update]
      end
    end
  end
end
