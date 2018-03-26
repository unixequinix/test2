module Admins
  module Events
    class Palco4Controller < Admins::Events::BaseController
      protect_from_forgery
      before_action :authenticate, only: %i[index]

      def index
        authorize @current_event, :palco4_index?
        redirect_to admins_event_ticket_types_path, alert: t("alerts.not_authorized") if @token.eql?("ERROR")
        redirect_to admins_event_palco4_show_path(@current_event, @current_event.palco4_event) if @current_event.palco4_event
        url = URI("https://test.palco4.com/accessControlApi/sessions/info/json?sVenues=1003")
        @sessions = api_response(url)
      end

      def show
        authorize @current_event, :palco4_show?
        url = URI("https://test.palco4.com/accessControlApi/barcodes/json/#{params[:p4_uuid]}")
        @current_event.update!(palco4_event: params[:p4_uuid])
        @tickets = api_response(url)
        @tickets&.each { |ticket| Palco4Importer.perform_now(ticket, @current_event) }
        flash[:notice] = "All tickets imported"
      end

      private

      def authenticate
        return @token = @current_event.palco4_token if @current_event.palco4_token
        url = URI("https://test.palco4.com/accessControlApi/users/login")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request.basic_auth(params[:user]["username"], params[:user]["password"])
        response = http.request(request)
        @token = response.body
        @current_event.update!(palco4_token: @token)
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
