Rails.application.routes.draw do
  get 'events/:event_id/transactions', to: 'transactions#index', as: "transactions"
end
