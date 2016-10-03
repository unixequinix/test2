class Companies::Api::V1::BannedGtagsController < Companies::Api::V1::BaseController
  def index
    render json: {
      event_id: current_event.id,
      blacklisted_gtags: @fetcher.banned_gtags.map do |gtag|
        Companies::Api::V1::GtagSerializer.new(gtag)
      end
    }
  end

  def create
    @gtag = @fetcher.gtags.find_by(tag_uid: params[:gtags_blacklist][:tag_uid])

    render(status: :not_found,
           json: { status: :not_found, message: :not_found }) && return unless @gtag

    @gtag.update!(banned: true)

    render(status: :created, json: @gtag, serializer: Companies::Api::V1::GtagSerializer)
  end

  def destroy
    gtag = @fetcher.banned_gtags.find_by(tag_uid: params[:id])
    render(status: :not_found,
           json: { status: :not_found, message: :not_found }) && return unless gtag

    gtag.update!(banned: false)
    render(status: :no_content, json: :no_content)
  end
end
