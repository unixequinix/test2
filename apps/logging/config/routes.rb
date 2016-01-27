Rails.application.routes.draw do
  get 'events/:event_id/logs', to: 'event_logs#index', as: "logs"
end
