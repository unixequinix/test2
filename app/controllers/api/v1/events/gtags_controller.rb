class Api::V1::Events::GtagsController < Api::V1::Events::BaseController
  def index
    modified = request.headers["If-Modified-Since"]
    gtags = sql_gtags(modified) || []

    if gtags.present?
      date = JSON.parse(gtags).map { |pr| pr["updated_at"] }.sort.last
      response.headers["Last-Modified"] = date.to_datetime.httpdate
    end

    status = gtags.present? ? 200 : 304 if modified
    status ||= 200

    render(status: status, json: gtags)
  end

  def show
    gtag = current_event.gtags.find_by_tag_uid(params[:id])

    render(json: :not_found, status: :not_found) && return unless gtag
    render(json: gtag, serializer: Api::V1::GtagSerializer)
  end
end
