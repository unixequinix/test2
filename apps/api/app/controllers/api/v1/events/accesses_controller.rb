class Api::V1::Events::AccessesController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.accesses, each_serializer: Api::V1::AccessSerializer
  end
end
