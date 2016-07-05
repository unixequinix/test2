class Api::V1::Events::DatabasesController < Api::V1::Events::BaseController
  def show # rubocop:disable Metrics/AbcSize
    database = if params[:basic] == "true"
                 current_event.device_basic_db
               else
                 current_event.device_full_db
               end

    render(status: :not_found, json: :not_found) && return unless database

    s3 = AWS::S3.new(access_key_id: Rails.application.secrets.s3_access_key_id,
                     secret_access_key: Rails.application.secrets.s3_secret_access_key)
    db = s3.buckets[Rails.application.secrets.s3_bucket].objects[database.path]
    render(status: :not_found, json: :not_found) && return if db.key.blank?

    url = db.url_for(:get, expires: 30.seconds.from_now, secure: true).to_s
    render(json: { url: url })
  end

  def create
    file = permitted_params[:file]
    render(status: :bad_request, json: { error: "File empty" }) && return unless file

    if permitted_params[:basic] == "true"
      current_event.device_basic_db = file
    else
      current_event.device_full_db = file
    end

    render(status: :created, json: :created) && return if current_event.save
    render(status: :unprocessable_entity, json: { errors: current_event.errors.full_messages })
  end

  private

  def permitted_params
    params.require(:database).permit(:file, :basic)
  end
end
