class Api::V1::Events::CreditsController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.credits, each_serializer: Api::V1::CreditSerializer
  end
end
