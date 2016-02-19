class Companies::Api::V1::BannedGtagsController < Companies::Api::V1::BaseController
  def index
    @banned_gtags = @fetcher.banned_gtags

    render json: {
      event_id: current_event.id,
      blacklisted_gtags: @banned_gtags.map { |gtag| Companies::Api::V1::GtagSerializer.new(gtag) }
    }
  end

  def create
    @gtag = @fetcher.gtags.find_by(tag_uid: params[:gtags_blacklist][:tag_uid])

    render(status: :not_found,
           json: { message: I18n.t("company_api.gtags.bad_request") }) && return unless @gtag

    @gtag.ban!
    render(status: :created, json: @gtag, serializer: Companies::Api::V1::GtagSerializer)
  end

  def destroy
    @banned_gtag = BannedGtag.includes(:gtag)
                   .find_by(gtags: { tag_uid: params[:id],
                                     event_id: current_event.id })

    render(status: :not_found, json: :not_found) && return if @banned_gtag.nil?
    render(status: :internal_server_error, json: :internal_server_error) &&
      return unless @banned_gtag.destroy
    render(status: :no_content, json: :no_content)
  end
end
