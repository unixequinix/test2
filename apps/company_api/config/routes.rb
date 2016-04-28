Rails.application.routes.draw do
  ## Thirdparty API
  ## ------------------------------

  namespace :companies do
    namespace :api, defaults: { format: "json" } do
      namespace :v1 do
        resources :banned_tickets, path: "tickets/blacklist", only: [:index, :create, :destroy]
        resources :banned_gtags, path: "gtags/blacklist", only: [:index, :create, :destroy]
        resources :gtags, only: [:index, :show, :create, :update]
        resources :tickets, only: [:index, :show, :create, :update] do
          post :bulk_upload, on: :collection
        end
        resources :ticket_types, only: [:index, :show, :create, :update]
      end
    end
  end
end
