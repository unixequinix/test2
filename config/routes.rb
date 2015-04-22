Rails.application.routes.draw do

  ## Devise
  ## ------------------------------

  devise_for :admins,
    controllers: {
      sessions: 'admin/sessions',
      passwords: 'admin/passwords'
    },
    path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' }

  devise_for :customers,
    controllers: {
      sessions: 'customer/sessions',
      registrations: 'customer/registrations',
      confirmations: 'customer/confirmations',
      passwords: 'customer/passwords'
    },
    path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' }

  ## Resources
  ## ------------------------------

  namespace :customer do
  end

  namespace :admin do
    resources :entitlements
    resources :ticket_types
    resources :tickets
  end

  devise_scope :customer do
    root to: 'customer/dashboards#show', as: :customer_root
  end

  devise_scope :admin do
    get 'admin', to: 'admin/dashboards#show', as: :admin_root
  end

  root to: 'customer/sessions#new'

end
