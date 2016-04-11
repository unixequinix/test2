class Api::V1::Events::GtagsController < Api::V1::Events::BaseController
  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    render(json: @fetcher.sql_gtags)
    # if request.headers["If-Modified-Since"]
    #   date = request.headers["If-Modified-Since"].to_time + 1
    #   @gtags = current_event.gtags
    #            .includes(:company_ticket_type, :credential_assignments, :purchaser)
    #            .where("gtags.updated_at > ?", date)
    #
    #   response.headers["Last-Modified"] = @gtags.maximum(:updated_at).to_s
    #
    #   render(json: @gtags, each_serializer: Api::V1::GtagSerializer)
    # else
    #
    #   last_updated = Rails.cache.fetch("v1/event/#{current_event.id}/gtags_updated_at",
    #                                    expires_in: 12.hours) do
    #     current_event.gtags.maximum(:updated_at).to_s
    #   end
    #
    #   response.headers["Last-Modified"] = last_updated
    #   render(json: Rails.cache.fetch("v1/event/#{current_event.id}/gtags",
    #                                  expires_in: 12.hours) { @fetcher.sql_gtags })
    # end
  end

  def show
    @gtag = current_event.gtags.find_by_id(params[:id])

    render(status: :not_found, json: :not_found) && return if @gtag.nil?
    render json: @gtag, serializer: Api::V1::GtagSerializer
  end
end
