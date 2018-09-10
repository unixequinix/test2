module Admins
  module Events
    class DeviceCachesController < Admins::Events::BaseController
      before_action :set_device_cache, only: %i[destroy]

      def destroy
        @device_cache.file.destroy
        @device_cache.file.clear
        @device_cache.destroy
        redirect_to admins_event_device_registrations_path(@current_event)
      end

      private

      def set_device_cache
        @device_cache = @current_event.device_caches.find(params[:id])
        authorize @device_cache
      end
    end
  end
end
