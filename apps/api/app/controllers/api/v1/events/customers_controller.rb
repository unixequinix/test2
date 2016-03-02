class Api::V1::Events::CustomersController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.customer_event_profiles,
           each_serializer: Api::V1::CustomerEventProfileSerializer
  end

  def show
    render json: @fetcher.customer_event_profiles.find_by(id: params[:id]),
           serializer: Api::V1::CustomerEventProfileSerializer
  end
end
