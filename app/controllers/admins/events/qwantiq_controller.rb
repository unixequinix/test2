module Admins
  module Events
    class QwantiqController < Admins::Events::BaseController
      protect_from_forgery
      before_action :set_integration

      def index
        redirect_to(%i[admins qwantiq auth]) && return unless @token

        @sessions = @integration.remote_events
      end

      def connect
        if @integration.update(integration_event_id: params[:p4_uuid], integration_event_name: params[:p4_name], status: "active")
          redirect_to [:admins, @current_event, @integration, :import_tickets]
        else
          redirect_to [:admins, @current_event, @integration], alert: "Event already connected, choose another"
        end
      end

      def import_tickets
        @integration.ignore_last_import_date = true
        @integration.import
        redirect_to [:admins, @current_event, :ticket_types], notice: "All tickets imported"
      end

      private

      def set_integration
        @integration = @current_event.qwantiq_ticketing_integrations.find(params[:ticketing_integration_id])
        authorize(@current_event.ticketing_integrations.new)
        cookies.signed[:ticketing_integration_id] = @integration.id
        cookies.signed[:event_slug] = @current_event.slug
        @token = @integration.token
      end
    end
  end
end
