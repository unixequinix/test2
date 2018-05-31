module Admins
  module Events
    class EventbriteController < Admins::Events::BaseController
      protect_from_forgery except: :webhooks
      skip_before_action :authenticate_user!, only: :webhooks
      before_action :set_params

      def index
        if @token.blank?
          atts = { response_type: :code, client_id: GlownetWeb.config.eventbrite_client_id }
          url = "#{GlownetWeb.config.eventbrite_auth_url}?#{atts.to_param}"
          cookies.signed[:event_slug] = @current_event.slug
          cookies.signed[:ticketing_integration_id] = @integration.id
          redirect_to(url)
        else
          @eb_events = @integration.remote_events.reject { |event| event.id.in? @current_event.eventbrite_ticketing_integrations.pluck(:integration_event_id) }
        end
      end

      def connect
        event_id = params[:eb_event_id]
        events = Eventbrite::User.owned_events({ user_id: "me" }, @token).events

        if @integration.update integration_event_id: event_id, integration_event_name: events.find { |e| e.id.eql? event_id }.name.text, status: "active"
          url = url_for([:admins, @current_event, @integration, :webhooks])
          actions = "order.placed,order.refunded,order.updated"
          Eventbrite::Webhook.create({ endpoint_url: url, event_id: event_id, actions: actions }, @token)
          redirect_to [:admins, @current_event, @integration, :import_tickets]
        else
          redirect_to [:admins, @current_event, @integration], alert: "Event already connected, choose another"
        end
      end

      def webhooks
        skip_authorization
        path = URI(params[:eventbrite][:api_url]).path.gsub("/" + Eventbrite::DEFAULTS[:api_version], "")
        resp, token = Eventbrite.request(:get, path, @token, expand: "attendees")
        order = Eventbrite::Util.convert_to_eventbrite_object(resp, token)

        Ticketing::EventbriteImporter.perform_later(order.to_json, @integration)
        head :ok
      end

      def import_tickets
        @integration.import
        redirect_to [:admins, @current_event, :ticket_types], notice: "All tickets imported"
      end

      private

      def set_params
        @integration = @current_event.eventbrite_ticketing_integrations.find(params[:ticketing_integration_id])
        authorize(@integration)
        @token = @integration.token
        return unless @token

        begin
          Eventbrite::User.retrieve("me", @token)
        rescue Eventbrite::AuthenticationError
          cookies.signed[:event_slug] = @current_event.slug
          cookies.signed[:ticketing_integration_id] = @integration.id
          @integration.update! token: nil
          redirect_to admins_eventbrite_auth_path
        end
      end
    end
  end
end
