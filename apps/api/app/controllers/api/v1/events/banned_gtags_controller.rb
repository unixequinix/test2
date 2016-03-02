class Api::V1::Events::BannedGtagsController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.banned_gtags, each_serializer: Api::V1::BannedGtagSerializer
  end
end
