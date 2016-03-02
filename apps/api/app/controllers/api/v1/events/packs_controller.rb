class Api::V1::Events::PacksController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.packs, each_serializer: Api::V1::PackSerializer
  end
end
