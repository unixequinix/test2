module Admins
  module Events
    class BaseController < Admins::BaseController
      layout "admin_event"

      before_action :set_event
      around_action :use_time_zone

      private

      def set_event
        @current_event = Event.friendly.find(params[:event_id])
        @event_registration = @current_user.registration_for(@current_event)
      end

      def use_time_zone
        Time.use_zone(@current_event.timezone) { yield }
      end
    end
  end
end
