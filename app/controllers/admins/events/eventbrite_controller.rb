class Admins::Events::EventbriteController < Admins::Events::BaseController
  protect_from_forgery except: :webhooks
  skip_before_action :authenticate_user!, only: :webhooks
  skip_after_action :verify_authorized, only: :webhooks
  before_action :check_token

  def index
    authorize @current_event, :eventbrite_index?
    session[:event_slug] = @current_event.slug
    atts = { response_type: :code, client_id: Rails.application.secrets.eventbrite_client_id }.to_param
    url = "https://www.eventbrite.com/oauth/authorize?#{atts}"
    redirect_to(url) && return unless @token.present?

    @eb_events = Eventbrite::User.owned_events({ user_id: "me" }, @token).events
    @eb_event = @eb_events.select { |event| event.id.eql? @current_event.eventbrite_event }.first
    @eb_attendees = Eventbrite::Attendee.all({ event_id: @eb_event.id }, @token).pagination.object_count if @eb_event
  end

  def connect
    authorize @current_event, :eventbrite_connect?
    event_id = params[:eb_event_id]
    @current_event.update eventbrite_event: event_id
    # url = "http://25883980.ngrok.io/admins/events/#{@current_event.slug}/eventbrite/webhooks"
    url = admins_event_eventbrite_webhooks_path(@current_event)
    actions = "order.placed,order.refunded,order.updated"
    Eventbrite::Webhook.create({ endpoint_path: url, event_id: event_id, actions: actions }, @token)
    redirect_to admins_event_eventbrite_import_tickets_path(@current_event)
  end

  def disconnect
    authorize @current_event, :eventbrite_disconnect?
    resp, token = Eventbrite.request(:get, "/webhooks", @token)
    webhooks = Eventbrite::Util.convert_to_eventbrite_object(resp, token, Eventbrite::Webhook).webhooks

    webhooks.select { |wh| wh.event_id == @current_event.eventbrite_event }.each do |wh|
      Eventbrite::Webhook.delete(wh.id, @token)
    end

    @current_event.update! eventbrite_token: nil, eventbrite_event: nil
    redirect_to admins_event_path(@current_event), notice: "Successfully disconnected form Eventbrite"
  end

  def webhooks
    authorize @current_event, :eventbrite_import_tickets?
    path = URI(params[:eventbrite][:api_path]).path.gsub("/" + Eventbrite::DEFAULTS[:api_version], "")
    resp, token = Eventbrite.request(:get, path, @token, expand: "attendees")
    order = Eventbrite::Util.convert_to_eventbrite_object(resp, token)

    EventbriteImporter.perform_later(order.to_json, @current_event.id)
    render nothing: true
  end

  def import_tickets
    eb_event = @current_event.eventbrite_event
    pages = Eventbrite::Order.all({ event_id: eb_event, expand: "attendees" }, @token).pagination.page_count

    pages.times do |page_number|
      orders = Eventbrite::Order.all({ event_id: eb_event, page: page_number, expand: "attendees" }, @token).orders
      orders.each { |order| EventbriteImporter.perform_later(order.to_json, @current_event.id) }
    end

    redirect_to admins_event_eventbrite_path(@current_event), notice: "All tickets imported"
  end

  private

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
