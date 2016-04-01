class Api::V1::Events::ProductsController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.products, each_serializer: Api::V1::ProductSerializer
  end
end
