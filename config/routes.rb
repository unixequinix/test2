Rails.application.routes.draw do

  ## Devise
  ## ------------------------------

  scope :customer do
    devise_for :customers,
    controllers: { sessions: 'customer/customers/sessions', passwords: 'customer/customers/passwords'},
      path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' }
  end


  ## Resources
  ## ------------------------------

  namespace :account do
    resources :accounts, only: [:show]
  end

  devise_scope :customer do
    root to: 'customer/customers#show', as: :customer_root
  end

  root to: 'customer/customers/sessions#new'

end
