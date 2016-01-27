require "api_constraints"

Rails.application.routes.draw do
  ## API
  ## ------------------------------

  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :events, only: [:index]  do
        scope module: "events" do
          resources :banned_tickets, path: "tickets/banned", only: [:index]
          resources :banned_gtags, path: "gtags/banned", only: [:index]
          resources :customers, only: [:index, :show]
          resources :gtags, only: [:index, :show]
          resources :orders, only: [:index]
          resources :preevent_products, only: [:index]
          resources :tickets, only: [:index, :show]
          get "/tickets/reference/:id", to: "tickets#reference"
          resources :refunds, only: [:index]
        end
      end
    end
  end
end
