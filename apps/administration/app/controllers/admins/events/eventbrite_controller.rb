class Admins::Events::EventbriteController < Admins::Events::BaseController
  def index
    render && return unless @current_event.eventbrite?
    Eventbrite.token = @current_event.eventbrite_token
    @eb_pagination = Eventbrite::Attendee.all(event_id: @current_event.eventbrite_event).pagination
  end

  def import_tickets
    @import_errors = []
    eb_event = @current_event.eventbrite_event
    @eb_pagination = Eventbrite::Attendee.all(event_id: eb_event).pagination
    Eventbrite.token = @current_event.eventbrite_token

    @eb_pagination.page_count.times do |page_number|
      Eventbrite::Attendee.all(event_id: eb_event, page: page_number).attendees.each do |attendee|
        attendee.barcodes.each do |barcode|
          ctt = @current_event.company_ticket_types.find_by_company_code(attendee.ticket_class_id)
          @import_errors << [attendee.ticket_class_id, attendee.ticket_class_name] && next unless ctt
          ctt.tickets.find_or_create_by!(code: barcode.barcode, event: @current_event)
        end
      end
    end

    if @import_errors.any?
      @import_errors = @import_errors.uniq
      flash.now.alert = "Errors prevented some tickets import"
      render :index
    else
      redirect_to admins_event_eventbrite_path(@current_event), notice: "All tickets imported"
    end
  end

  def disconnect
    @current_event.update(eventbrite_token: nil)
    redirect_to admins_event_eventbrite_path(@current_event), success: "Eventbrite successfully disconnected"
  end

  def connect
    key = params[:event][:eventbrite_client_key]
    secret = params[:event][:eventbrite_client_secret]
    redirect_to(:index, error: "Both fields are necessary") && return unless key && secret
    @current_event.update(eventbrite_client_key: key, eventbrite_client_secret: secret)
    redirect_to "https://www.eventbrite.com/oauth/authorize?response_type=code&client_id=#{params[:event][:eventbrite_client_key]}" # rubocop:disable Metrics/LineLength
  end

  def auth
    @params = { code: params[:code],
                client_secret: @current_event.eventbrite_client_secret,
                client_id: @current_event.eventbrite_client_key,
                grant_type: "authorization_code" }

    uri = URI.parse("https://www.eventbrite.com/oauth/token")
    token = JSON.parse(Net::HTTP.post_form(uri, @params).body)["access_token"]
    @current_event.update(eventbrite_token: token)

    redirect_to admins_event_eventbrite_path(@current_event), success: "Eventbrite successfully connected"
  end
end
