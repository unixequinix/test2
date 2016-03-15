class Api::V1::Events::CustomersController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.sql_customer_event_profiles
  end

  def show
    @cep = current_event.customer_event_profiles
           .joins(:customer, :credential_assignments, :orders)
           .find_by(id: params[:id])

    render json: @cep, serializer: Api::V1::CustomerEventProfileSerializer
  end
end
