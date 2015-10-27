Rails.application.routes.draw do

  resources :locale do
    member do
      get 'change'
    end
  end

  root to: 'customers/dashboards#show'
end
