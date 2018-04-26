module Admins
  module Events
    class UniverseController < Admins::Events::BaseController
      protect_from_forgery
      before_action :set_params

      def index
        cookies.signed[:event_slug] = @current_event.slug

        atts = { client_id: GlownetWeb.config.universe_client_id, response_type: :code, redirect_uri: GlownetWeb.config.universe_app_url, response_params: { event_slug: @current_event.slug } }
        redirect_to("#{GlownetWeb.config.universe_auth_url}?#{atts.to_param}") && return if @token.blank?

        @uv_events = universe_events.reject { |event| event.id.in? @current_event.universe_ticketing_integrations.pluck(:integration_event_id) }
        @uv_event = @uv_events.find { |event| @integration.integration_event_id.eql? event.id }
        @uv_attendees = universe_attendees
      end

      def connect
        atts = { integration_event_id: params[:uv_event_id], integration_event_name: universe_events.find { |event| params[:uv_event_id].eql? event.id }.title, status: "active" }

        redirect_to [:admins, @current_event, @integration], alert: "Event already connected, choose another" unless @integration.update atts
        redirect_to [:admins, @current_event, @integration, :import_tickets]
      end

      def import_tickets
        @integration.import
        redirect_to [:admins, @current_event, :ticket_types], notice: "All tickets imported"
      end

      private

      def set_params
        @integration = @current_event.universe_ticketing_integrations.find(params[:ticketing_integration_id])
        authorize(@integration)
        cookies.signed[:ticketing_integration_id] = @integration.id
        @token = @integration.token
      end

      def universe_events
        user_id = @integration.api_response(URI(GlownetWeb.config.universe_user_url))["current_user"]["id"]
        data = @integration.api_response(URI("#{GlownetWeb.config.universe_listings_url}?user_id=#{user_id}"))

        data["listings"].map do |listing|
          event_data = data["events"].find { |event| event["id"] == listing["event_id"] }
          Hashie::Mash.new listing.merge(event_data)
        end
      end

      def universe_attendees
        url = URI("#{GlownetWeb.config.universe_barcodes_url}?event_id=#{@integration.integration_event_id}")
        @uv_attendees = @integration.api_response(url)["meta"]["count"]
      end
    end
  end
end
