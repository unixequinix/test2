class EventTransactionsController < ApplicationController
  layout "admin_event"

  before_filter :fetch_current_event

  def index
    @logs = EventTransaction.all.group_by(&:type)
  end

  private

  def fetch_current_event
    @current_event = Event.find_by_slug!(params[:event_id] || params[:id])
  end
end