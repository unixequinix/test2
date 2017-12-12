class Admins::Events::EventbriteController < Admins::Events::BaseController
  protect_from_forgery except: :webhooks
  skip_before_action :authenticate_user!, only: :webhooks
  before_action :set_params

  def index
    authorize @current_event, :eventbrite_index?
    cookies.signed[:event_slug] = @current_event.slug
    client = Rails.application.secrets.eventbrite_client_id
    atts = { response_type: :code, client_id: client, response_params: { event_slug: @current_event.slug } }.to_param
    url = "https://www.eventbrite.com/oauth/authorize?#{atts}"
    redirect_to(url) && return if @token.blank?

    @eb_events = Eventbrite::User.owned_events({ user_id: "me" }, @token).events
    @eb_event = @eb_events.select { |event| event.id.eql? @current_event.eventbrite_event }.first
    @eb_attendees = Eventbrite::Attendee.all({ event_id: @eb_event.id }, @token).pagination.object_count if @eb_event
  end

  def connect
    authorize @current_event, :eventbrite_connect?
    event_id = params[:eb_event_id]
    @current_event.update eventbrite_event: event_id
    # url = "http://glownet.ngrok.io/admins/events/#{@current_event.slug}/eventbrite/webhooks"
    url = admins_event_eventbrite_webhooks_url(@current_event)
    actions = "order.placed,order.refunded,order.updated"
    Eventbrite::Webhook.create({ endpoint_url: url, event_id: event_id, actions: actions }, @token)
    redirect_to admins_event_eventbrite_import_tickets_path(@current_event)
  end

  def disconnect
    authorize @current_event, :eventbrite_disconnect?
    resp, token = Eventbrite.request(:get, "/webhooks", @token)
    webhooks = Eventbrite::Util.convert_to_eventbrite_object(resp, token, Eventbrite::Webhook).webhooks

    webhooks.select { |wh| wh.event_id == @current_event.eventbrite_event }.each do |wh|
      Eventbrite::Webhook.delete(wh.id, @token)
    end

    name = "Eventbrite - #{@current_event.eventbrite_event}"
    @current_event.tickets.where(ticket_type: @current_event.companies.find_by(name: name)&.ticket_types).update_all(banned: true)
    @current_event.update! eventbrite_token: nil, eventbrite_event: nil
    redirect_to admins_event_path(@current_event), notice: "Successfully disconnected form Eventbrite"
  end

  def disconnect_event
    authorize @current_event, :eventbrite_disconnect?
    resp, token = Eventbrite.request(:get, "/webhooks", @token)
    webhooks = Eventbrite::Util.convert_to_eventbrite_object(resp, token, Eventbrite::Webhook).webhooks

    webhooks.select { |wh| wh.event_id == @current_event.eventbrite_event }.each do |wh|
      Eventbrite::Webhook.delete(wh.id, @token)
    end

    name = "Eventbrite - #{@current_event.eventbrite_event}"
    @current_event.tickets.where(ticket_type: @current_event.companies.find_by(name: name).ticket_types).update_all(banned: true)
    @current_event.update! eventbrite_event: nil
    redirect_to admins_event_eventbrite_path(@current_event), notice: "Successfully disconnected form Eventbrite Event"
  end

  def webhooks
    skip_authorization
    path = URI(params[:eventbrite][:api_url]).path.gsub("/" + Eventbrite::DEFAULTS[:api_version], "")
    resp, token = Eventbrite.request(:get, path, @token, expand: "attendees")
    order = Eventbrite::Util.convert_to_eventbrite_object(resp, token)

    EventbriteImporter.perform_later(order.to_json, @current_event.id)
    head :ok
  end

  def import_tickets
    authorize @current_event, :eventbrite_import_tickets?
    eb_event = @current_event.eventbrite_event
    first_call = Eventbrite::Order.all({ event_id: eb_event, page: 1, expand: "attendees" }, @token)
    first_call.orders.each { |order| EventbriteImporter.perform_later(order.to_json, @current_event.id) }

    pages = first_call.pagination.page_count
    (2..pages).to_a.each do |page_number|
      orders = Eventbrite::Order.all({ event_id: eb_event, page: page_number, expand: "attendees" }, @token).orders
      orders.each { |order| EventbriteImporter.perform_later(order.to_json, @current_event.id) }
    end

    redirect_to admins_event_eventbrite_path(@current_event), notice: "All tickets imported"
  end

  private

  def set_params
    @token = @current_event.eventbrite_token
    return unless @token
    begin
      Eventbrite::User.retrieve("me", @token)
    rescue Eventbrite::AuthenticationError
      cookies.signed[:event_slug] = @current_event.slug
      @current_event.update! eventbrite_token: nil
      redirect_to admins_eventbrite_auth_path
    end
  end
end
