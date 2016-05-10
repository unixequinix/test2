class Api::V1::Events::GtagsController < Api::V1::Events::BaseController
  def index
    render(json: @fetcher.sql_gtags)
  end

  def show
    @gtag = current_event.gtags.find_by_id(params[:id])

    render(status: :not_found, json: :not_found) && return if @gtag.nil?
    render json: @gtag, serializer: Api::V1::GtagWithCustomerSerializer
  end
end
