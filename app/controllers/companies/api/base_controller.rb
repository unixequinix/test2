module Companies::Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    serialization_scope :view_context

    before_action :restrict_access_with_http

    private

    def restrict_access_with_http
      authenticate_or_request_with_http_basic do |event_token, company_token|
        @current_event = Event.find_by(token: event_token)
        @company = @current_event&.companies&.find_by(access_token: company_token)
        @current_event && @company && !@current_event.closed? && @current_event.open_ticketing_api? || render(status: 403, json: :unauthorized)
      end
    end

    def ticket_types
      @company.ticket_types
    end

    def tickets
      @current_event.tickets.joins(:ticket_type).where(ticket_types: { company_id: @company.id })
    end

    def banned_tickets
      tickets.where(banned: true)
    end
  end
end
