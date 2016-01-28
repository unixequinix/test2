Rails.application.routes.draw do
  get 'events/:event_id/logs', to: 'transactions#index', as: "logs"
end
