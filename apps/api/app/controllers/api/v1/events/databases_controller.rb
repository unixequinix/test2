class Api::V1::Events::DatabasesController < Api::V1::Events::BaseController
  def show
    database = current_event.device_database
    render(status: :not_found, json: :not_found) && return unless database

    s3 = AWS::S3.new(
      access_key_id: Rails.application.secrets.s3_access_key_id,
      secret_access_key: Rails.application.secrets.s3_secret_access_key
    )
    db = s3.buckets[Rails.application.secrets.s3_bucket].objects[database.path]
    url = db.url_for(:get, { expires: 30.seconds.from_now, secure: true }).to_s
    render(json: { url: url })
  end

  def create
    render(status: :bad_request, json: { error: "file empty" }) && return unless params[:file]
    current_event.device_database = params[:file]

    render(status: :created, json: :created) && return if current_event.save
    render(status: :unprocessable_entity, json: { errors: current_event.errors.full_messages })
  end
end
