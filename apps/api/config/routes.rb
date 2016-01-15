require 'api_constraints'

Rails.application.routes.draw do
  ## API
  ## ------------------------------

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1,
          constraints: ApiConstraints.new(version: 1, default: true) do
      resources :events, only: [:index]  do
        scope module: 'events' do
          resources :customer_event_profiles, only: [:index]
          resources :orders, only: [:index]
          resources :tickets, only: [:index]
          resources :refunds, only: [:index]
        end
      end
    end
  end
end
