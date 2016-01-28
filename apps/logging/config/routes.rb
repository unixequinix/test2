Rails.application.routes.draw do
  get 'events/:event_id/logs', to: 'event_transactions#index', as: "logs"
end
