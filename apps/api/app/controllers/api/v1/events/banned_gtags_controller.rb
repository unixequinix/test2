class Api::V1::Events::BannedGtagsController < Api::V1::Events::BaseController
  def index
    @banned_gtags = Gtag.banned.where(event: current_event)
    render json: @banned_gtags, each_serializer: Api::V1::BannedGtagSerializer
  end
end
