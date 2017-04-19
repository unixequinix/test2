class Events::EventsController < ApplicationController
  include LanguageHelper

  layout "customer"
  protect_from_forgery
  before_action :fetch_current_event
  before_action :authenticate_customer!
  before_action :resolve_locale

  helper_method :current_event
  helper_method :current_customer

  def show
    @any_tickets = TicketType.where.not(catalog_item: nil).where(hidden: false).includes(:tickets).merge(@current_event.tickets.where(banned: false)).any? # rubocop:disable Metrics/LineLength
    @any_gtags = @current_event.gtags.any?
    @orders = @current_customer.orders.order(created_at: :desc).where(status: %w[completed refunded])
    @refunds = @current_customer.refunds.order(created_at: :desc)
  end

  def authenticate_customer!
    redirect_to(event_login_path(@current_event)) && return unless customer_signed_in?
    redirect_to(customer_root_path(current_customer.event)) && return unless current_customer.event == @current_event
    super
  end
end
