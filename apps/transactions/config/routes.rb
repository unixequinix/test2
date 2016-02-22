Rails.application.routes.draw do
  resources :tests, only: [:create]

  ## API
  ## ------------------------------
  namespace :transactions do
    namespace :api, defaults: { format: "json" } do
      namespace :v1 do
        resources :transactions, only: [:create]
      end
    end
  end
end
