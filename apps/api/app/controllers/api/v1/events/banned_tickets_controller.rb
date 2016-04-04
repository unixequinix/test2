class Api::V1::Events::BannedTicketsController < Api::V1::Events::BaseController
  def index
    render_entities("banned_ticket")
  end
end
