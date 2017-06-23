class Events::CredentialsController < ApplicationController
  include LanguageHelper

  before_action :resolve_locale
  before_action :set_event

  layout "customer"

  def new
    @credential = @current_event.gtags.new
  end

  def create
    @credential = @current_event.gtags.find_by(tag_uid: reference) if @current_event.open_gtags?
    @credential ||= @current_event.tickets.find_by(code: reference) if @current_event.open_tickets?
    @credential ||= @current_event.gtags.new(tag_uid: reference)

    item = { item: I18n.t("credentials.name") }
    @credential.errors.add(:reference, I18n.t("credentials.already_assigned", item)) if @credential.customer_not_anonymous?

    if @credential.validate_assignation
      session[:credential_id] = @credential.id
      session[:credential_type] = @credential.class.to_s
      session[:customer_id] = @credential.customer_id
      redirect_to event_register_path(@current_event)
    else
      render :new
    end
  end

  private

  def reference
    (params[:gtag] && params[:gtag][:reference]) || (params[:ticket] && params[:ticket][:reference])
  end

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end
end
