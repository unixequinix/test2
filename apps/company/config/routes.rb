Rails.application.routes.draw do
  ## Thirdparty API
  ## ------------------------------

  namespace :companies do
    namespace :api, defaults: { format: 'json' } do
      namespace :v1 do
        resources :events, only: [:index]
      end
    end
  end
end
