class Api::V1::Events::GtagsController < Api::V1::Events::BaseController
  def index
    modified = request.headers["If-Modified-Since"]
    gtags = @fetcher.sql_gtags(modified) || []

    if gtags
      date = JSON.parse(gtags).map { |pr| pr["updated_at"] }.sort.last
      response.headers["Last-Modified"] = date.to_datetime.httpdate
    end

    render(json: gtags)
  end

  def show
    serializer = Api::V1::GtagWithCustomerSerializer
    @gtag = current_event.gtags.find_by_tag_uid(params[:id])
    render(json: @gtag, serializer: serializer) && return if @gtag
    render(json: :not_found, status: :not_found)
  end
end
