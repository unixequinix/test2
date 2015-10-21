Rails.application.routes.draw do

  resources :locale do
    member do
      get 'change'
    end
  end

  ## Devise
  ## ------------------------------

  devise_for :admins,
    controllers: {
      sessions: 'admins/sessions',
      passwords: 'admins/passwords'
    },
    path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' },
    class_name: "Shared::Admin"

  devise_scope :customers do
    get ':event_id', to: 'events/events#show', as: :customer_root,
    class_name: "Shared::User"
  end
end
