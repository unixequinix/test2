class Admins::Events::EventbriteController < Admins::Events::BaseController
  protect_from_forgery except: :webhooks
  skip_before_action :authenticate_admin!, only: :webhooks
  before_action :set_agreement, only: [:webhooks, :import_tickets]
  before_action :check_token

  def index
    session[:event_slug] = @current_event.slug
    url = "https://www.eventbrite.com/oauth/authorize?response_type=code&client_id=#{secrets.eventbrite_client_id}"
    redirect_to(url) && return unless @token.present?

    @eb_events = Eventbrite::User.owned_events({ user_id: "me" }, @token).events
    @eb_event = @eb_events.select { |event| event.id.eql? @current_event.eventbrite_event }.first
    @eb_attendees = Eventbrite::Attendee.all({ event_id: @eb_event.id }, @token).pagination.object_count if @eb_event
  end

  def connect
    event_id = params[:eb_event_id]
    @current_event.update eventbrite_event: event_id
    # url = "http://25883980.ngrok.io/admins/events/#{@current_event.slug}/eventbrite/webhooks"
    url = admins_event_eventbrite_webhooks_url(@current_event)
    actions = "order.placed,order.refunded,order.updated"
    Eventbrite::Webhook.create({ endpoint_url: url, event_id: event_id, actions: actions }, @token)
    redirect_to admins_event_eventbrite_import_tickets_path(@current_event)
  end

  def disconnect
    resp, token = Eventbrite.request(:get, "/webhooks", @token)
    webhooks = Eventbrite::Util.convert_to_eventbrite_object(resp, token, Eventbrite::Webhook).webhooks

    webhooks.select { |wh| wh.event_id == @current_event.eventbrite_event }.each do |wh|
      Eventbrite::Webhook.delete(wh.id, @token)
    end

    @current_event.update! eventbrite_token: nil, eventbrite_event: nil
    redirect_to admins_event_path(@current_event), notice: "Successfully disconnected form Eventbrite"
  end

  def webhooks
    path = URI(params[:eventbrite][:api_url]).path.gsub("/" + Eventbrite::DEFAULTS[:api_version], "")
    resp, token = Eventbrite.request(:get, path, @token, expand: "attendees")
    order = Eventbrite::Util.convert_to_eventbrite_object(resp, token)

    process_order(order)
    render nothing: true
  end

  def import_tickets
    eb_event = @current_event.eventbrite_event
    pages = Eventbrite::Order.all({ event_id: eb_event, expand: "attendees" }, @token).pagination.page_count

    pages.times do |page_number|
      orders = Eventbrite::Order.all({ event_id: eb_event, page: page_number, expand: "attendees" }, @token).orders
      orders.each { |order| process_order(order) }
    end

    redirect_to admins_event_eventbrite_path(@current_event), notice: "All tickets imported"
  end

  private

  def process_order(order)
    barcodes = order.attendees.map(&:barcodes).flatten.map(&:barcode)
    @current_event.tickets.where(code: barcodes).destroy_all && return unless order.status.eql?("placed")

    ticket_types = @current_event.company_ticket_types.where(company_event_agreement: @agreement)

    order.attendees.each do |attendee|
      attendee.barcodes.each do |barcode|
        ctt = ticket_types.find_or_create_by!(company_code: attendee.ticket_class_id, name: attendee.ticket_class_name)
        ticket = ctt.tickets.find_or_create_by!(code: barcode.barcode, event: @current_event)
        profile = attendee.profile
        purchaser = ticket.purchaser || ticket.build_purchaser

        purchaser.update! first_name: profile.first_name, last_name: profile.last_name, email: profile.email
      end
    end
  end

  def set_agreement
    company = Company.find_or_create_by!(name: "Eventbrite")
    @agreement = CompanyEventAgreement.find_or_create_by!(event: @current_event, company: company)
  end

  def check_token
    @token = @current_event.eventbrite_token
    return unless @token
    begin
      Eventbrite::User.retrieve("me", @token)
    rescue Eventbrite::AuthenticationError
      session[:event_slug] = @current_event.slug
      @current_event.update! eventbrite_token: nil
      redirect_to admins_eventbrite_auth_path
    end
  end
end
