class Api::V1::Events::GtagsController < Api::V1::Events::BaseController
  def index
    render(json: @fetcher.sql_gtags)
  end

  def show
    serializer = Api::V1::GtagWithCustomerSerializer
    @gtag = current_event.gtags.find_by_tag_uid(params[:id])
    render(json: @gtag, serializer: serializer) && return if @gtag
    render(json: :not_found, status: :not_found)
  end
end
