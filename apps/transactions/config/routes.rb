Rails.application.routes.draw do
  namespace :admins do
  end

  ## API
  ## ------------------------------
  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :events, only: [:index]  do
        scope module: "events" do
          resources :transactions, only: [:create]
        end
      end
    end
  end
end
