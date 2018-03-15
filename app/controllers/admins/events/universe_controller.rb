module Admins
  module Events
    class UniverseController < Admins::Events::BaseController
      protect_from_forgery
      before_action :set_params

      def index
        authorize @current_event, :universe_index?
        cookies.signed[:event_slug] = @current_event.slug
        client = Figaro.env.universe_client_id
        app_uri = Figaro.env.universe_app_uri
        atts = { client_id: client, response_type: :code, redirect_uri: app_uri, response_params: { event_slug: @current_event.slug } }.to_param
        url = "https://www.universe.com/oauth/authorize?#{atts}"
        redirect_to(url) && return if @token.blank?

        import_tickets(false)
        @uv_events = universe_events
        @uv_event = @uv_events.find { |event| @current_event.universe_event.eql? event.id }
        @uv_attendees = universe_attendees
      end

      def connect
        authorize @current_event, :universe_connect?
        @current_event.update universe_event: params[:uv_event_id]
        redirect_to admins_event_universe_import_tickets_path(@current_event)
      end

      def disconnect
        authorize @current_event, :universe_disconnect?
        @current_event.tickets.where(ticket_type: @current_event.ticket_types.where(company: "Universe - #{@current_event.universe_event}")).update_all(banned: true)
        @current_event.update! universe_token: nil, universe_event: nil
        redirect_to admins_event_path(@current_event), notice: "Successfully disconnected from Universe"
      end

      def disconnect_event
        authorize @current_event, :universe_disconnect?
        @current_event.tickets.where(ticket_type: @current_event.ticket_types.where(company: "Universe - #{@current_event.universe_event}")).update_all(banned: true)
        @current_event.update! universe_event: nil
        redirect_to admins_event_universe_path(@current_event), notice: "Successfully disconnected from Universe Event"
      end

      def import_tickets(update = true)
        authorize @current_event, :universe_import_tickets?
        uv_event = @current_event.universe_event
        url = URI("https://www.universe.com/api/v2/guestlists?event_id=#{uv_event}")
        data = api_response(url)
        tickets_count, tickets_api_limit = data["meta"].values_at("count", "limit")

        ((tickets_count / tickets_api_limit) + 1).times do |page_number|
          atts = { event_id: uv_event, limit: tickets_api_limit, offset: tickets_api_limit * page_number }.to_param
          url = URI("https://www.universe.com/api/v2/guestlists?#{atts}")
          data = api_response(url)
          data["data"]["guestlist"].each { |ticket| UniverseImporter.perform_later(ticket, @current_event) }
        end

        redirect_to admins_event_universe_path(@current_event), notice: "All tickets imported" if update
      end

      private

      def set_params
        @token = @current_event.universe_token
        return unless @token

        @user_id = api_response(URI("https://www.universe.com/api/v2/current_user"))["current_user"]["id"]
      end

      def universe_events
        data = api_response(URI("https://www.universe.com/api/v2/listings?user_id=#{@user_id}"))

        data["listings"].map do |listing|
          event_data = data["events"].find { |event| event["id"] == listing["event_id"] }
          Hashie::Mash.new listing.merge(event_data)
        end
      end

      def universe_attendees
        url = URI("https://www.universe.com/api/v2/guestlists?event_id=#{@current_event.universe_event}")
        @uv_attendees = api_response(url)["meta"]["count"]
      end

      def api_response(url)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request["authorization"] = "Bearer #{@token}"
        @response = JSON.parse(http.request(request).body)
      end
    end
  end
end
