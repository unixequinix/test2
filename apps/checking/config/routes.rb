Rails.application.routes.draw do

  namespace :admins do
    resources :events, only: [] do
      scope module: "events" do
        resources :gtags do
          resources :comments, module: :gtags
          collection do
            get :search
            delete :destroy_multiple
          end
        end
        resources :entitlements, except: :show
        resources :ticket_types, except: :show
        resources :tickets do
          resources :comments, module: :tickets
          collection do
            get :search
            delete :destroy_multiple
          end
        end
        resources :gtag_registrations, only: [:destroy]
        resources :customer_event_profiles, only: [] do
          resources :admissions, only: [:new, :create]
          resources :gtag_registrations, only: [:new, :create]
          collection do
            get :search
          end
        end
      end
    end
  end
end
