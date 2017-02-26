class Events::EventsController < ApplicationController
  layout "welcome_customer"
  protect_from_forgery
  before_action :fetch_current_event
  before_action :authenticate_customer!
  before_action :write_locale_to_session
  helper_method :current_event
  helper_method :current_customer

  def show
    @any_tickets = TicketType.where.not(catalog_item: nil).where(hidden: false).includes(:tickets).merge(@current_event.tickets.where(banned: false)).any? # rubocop:disable Metrics/LineLength
  end

  private

  def write_locale_to_session
    super(Event::LOCALES.map(&:to_s))
  end

  def authenticate_customer!
    redirect_to(event_login_path(@current_event)) && return unless customer_signed_in?
    redirect_to(customer_root_path(current_customer.event)) && return unless current_customer.event == @current_event
    super
  end
end
