class Admins::Events::EventbriteController < Admins::Events::BaseController
  def index
    begin
      render && return unless @current_event.eventbrite?
      Eventbrite.token = @current_event.eventbrite_token
      @attendees = Eventbrite::Attendee.all({ event_id: @current_event.eventbrite_event })[:attendees]
    rescue Eventbrite::APIError => e
      @attendees = []
      flash.now.error = e.json_body[:error].message
    end
    @tickets = @current_event.tickets
  end

  def import_tickets
    Eventbrite.token = @current_event.eventbrite_token
    attendees = Eventbrite::Attendee.all({ event_id: @current_event.eventbrite_event })[:attendees]
    attendees.each do |attendee|
      attendee.barcodes.each do |barcode|
        ctt = @current_event.company_ticket_types.find_by_company_code(attendee.ticket_class_id)
        error = "Company ticket type with company code #{attendee.ticket_class_id} (#{attendee.ticket_class_name}) not found, please create it"
        redirect_to(admins_event_eventbrite_path(@current_event), alert: error) && return unless ctt

        ctt.tickets.find_or_create_by!(code: barcode.barcode, event: @current_event)
      end
    end
    redirect_to admins_event_eventbrite_path(@current_event), notice: "All tickets imported"
  end

  def disconnect
    @current_event.update(eventbrite_token: nil)
    redirect_to admins_event_eventbrite_path(@current_event), success: "Eventbrite successfully disconnected"
  end

  def connect
    key = params[:event][:eventbrite_client_key]
    secret = params[:event][:eventbrite_client_secret]
    redirect_to :index, error: "Both fields are necessary" and return unless key && secret
    @current_event.update(eventbrite_client_key: key, eventbrite_client_secret: secret)
    redirect_to "https://www.eventbrite.com/oauth/authorize?response_type=code&client_id=#{params[:event][:eventbrite_client_key]}"
  end

  def auth
    @params = { code: params[:code],
                client_secret: @current_event.eventbrite_client_secret,
                client_id: @current_event.eventbrite_client_key,
                grant_type: 'authorization_code' }

    uri = URI.parse("https://www.eventbrite.com/oauth/token")
    token = JSON.parse(Net::HTTP.post_form(uri, @params).body)["access_token"]
    @current_event.update(eventbrite_token: token)

    redirect_to admins_event_eventbrite_path(@current_event), success: "Eventbrite successfully connected"
  end
end
