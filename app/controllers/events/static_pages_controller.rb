class Events::StaticPagesController < Events::EventsController
  layout "welcome_customer"
  skip_before_action :authenticate_customer!
end
