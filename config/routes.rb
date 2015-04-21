Rails.application.routes.draw do

  ## Devise
  ## ------------------------------

  scope :admin do
    devise_for :admins,
      controllers: {
        sessions: 'admin/admins/sessions',
        passwords: 'admin/admins/passwords'
      },
      path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' }
  end

  scope :customer do
    devise_for :customers,
      controllers: {
        sessions: 'customer/customers/sessions',
        registrations: 'customer/customers/registrations',
        confirmations: 'customer/customers/confirmations',
        passwords: 'customer/customers/passwords'
      },
      path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' }
  end

  ## Resources
  ## ------------------------------

  namespace :customer do
    resources :customers, only: [:show]
  end

  namespace :admin do
  end

  devise_scope :customer do
    root to: 'customer/customers#show', as: :customer_root
  end

  devise_scope :admin do
    root to: 'admin/dashboards#show', as: :admin_root
  end

  root to: 'customer/customers/sessions#new'

end
