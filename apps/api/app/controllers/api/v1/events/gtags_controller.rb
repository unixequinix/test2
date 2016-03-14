class Api::V1::Events::GtagsController < Api::V1::Events::BaseController
  def index
    # TODO: Cache should refresh if there are changes
    # json = Rails.cache.fetch("v1/gtags", expires_in: 12.hours) do
    @gtags = @fetcher.sql_gtags

    render json: @gtags
  end

  def show
    @gtag = current_event.gtags.find_by_id(params[:id])

    render(status: :not_found, json: :not_found) && return if @gtag.nil?
    render json: @gtag, serializer: Api::V1::GtagSerializer
  end
end
