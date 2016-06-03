require "api_constraints"

Rails.application.routes.draw do
  ## API
  ## ------------------------------

  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :events, only: :index do
        scope module: "events" do
          resources :accesses, only: :index
          resources :auto_top_ups, only: :create
          resources :backups, only: :create
          resources :banned_gtags, path: "gtags/banned", only: :index
          resources :banned_tickets, path: "tickets/banned", only: :index
          resources :company_ticket_types, only: :index
          resources :credential_types, only: :index
          resources :credits, only: :index
          resources :customers, only: [:index, :show]
          resources :gtags, only: [:index, :show]
          resources :orders, only: :index
          resources :packs, only: :index
          resources :parameters, only: :index
          resources :products, only: :index
          resources :stations, only: :index
          resources :tickets, only: [:index, :show]
          resources :vouchers, only: :index
          get "/time", to: "time#index"
        end
      end
    end
  end
end
