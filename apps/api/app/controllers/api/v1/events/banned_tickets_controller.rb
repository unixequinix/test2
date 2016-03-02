class Api::V1::Events::BannedTicketsController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.banned_tickets, each_serializer: Api::V1::BannedTicketSerializer
  end
end
