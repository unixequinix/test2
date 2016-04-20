class Api::V1::Events::TicketsController < Api::V1::Events::BaseController
  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    render(json: @fetcher.sql_tickets)
    # if request.headers["If-Modified-Since"]
    #   date = request.headers["If-Modified-Since"].to_time + 1
    #   @tickets = current_event.tickets
    #              .includes(:company_ticket_type, :credential_assignments, :purchaser)
    #              .where("tickets.updated_at > ?", date)
    #
    #   response.headers["Last-Modified"] = @tickets.maximum(:updated_at).to_s
    #
    #   render(json: @tickets, each_serializer: Api::V1::TicketSerializer)
    # else
    #
    #   last_updated = Rails.cache.fetch("v1/event/#{current_event.id}/tickets_updated_at",
    #                                    expires_in: 12.hours) do
    #     current_event.tickets.maximum(:updated_at).to_s
    #   end
    #
    #   response.headers["Last-Modified"] = last_updated
    #   render(json: Rails.cache.fetch("v1/event/#{current_event.id}/tickets",
    #                                  expires_in: 12.hours) { @fetcher.sql_tickets })
    # end
  end

  def show
    @ticket = current_event.tickets.find_by_id(params[:id])

    render(status: :not_found, json: :not_found) && return if @ticket.nil?
    render(json: @ticket, serializer: Api::V1::TicketWithCustomerSerializer)
  end

  def reference
    @ticket = current_event.tickets.find_by_code(params[:id])

    render(status: :not_found, json: :not_found) && return if @ticket.nil?
    render(json: @ticket, serializer: Api::V1::TicketWithCustomerSerializer)
  end
end
