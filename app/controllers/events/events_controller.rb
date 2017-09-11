class Events::EventsController < ApplicationController
  include LanguageHelper

  layout "customer"
  protect_from_forgery
  before_action :set_event
  before_action :authenticate_customer!
  before_action :resolve_locale
  before_action :check_portal_open

  def show
    @any_tickets = TicketType.where.not(catalog_item: nil).where(hidden: false).joins(:tickets).merge(@current_event.tickets.where(banned: false)).any? # rubocop:disable Metrics/LineLength
    @any_gtags = @current_event.gtags.any?
    @orders = @current_customer.orders.order(created_at: :desc).where(status: %w[completed refunded])
    @refunds = @current_customer.refunds.order(created_at: :desc)
  end

  private

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end

  def check_portal_open
    return true if @current_event.open_portal?
    sign_out(@current_customer)
    redirect_to(event_login_path(@current_event))
  end

  def authenticate_customer!
    redirect_to(event_login_path(@current_event)) && return unless customer_signed_in?
    redirect_to(customer_root_path(@current_customer.event)) unless @current_customer.event == @current_event
    super
  end
end
