Rails.application.routes.draw do
  ## Thirdparty API
  ## ------------------------------

  namespace :companies do
    namespace :api, defaults: { format: 'json' } do
      namespace :v1 do
        resources :tickets, only: [:index, :show]
      end
    end
  end
end
