class Api::V1::Events::BackupsController < Api::V1::Events::BaseController
  def create
    keys = [:device_uid, :backup_created_at, :backup].any? { |i| params[i] }

    secrets = Rails.application.secrets
    s3 = AWS::S3.new(access_key_id: secrets.s3_access_key_id, secret_access_key: secrets.s3_secret_access_key)

    time = Time.parse(params[:backup_created_at]).to_i
    name = "gspot/event/#{params[:event_id]}/backups/#{params[:device_uid]}/#{params[:device_uid]}-#{time}"
    obj = s3.bucket(Rails.application.secrets.s3_bucket).object(name)

    obj.upload_file(params[:backup])

    render(status: :bad_request, json: { error: "params missing" }) && return unless keys
    render(status: :created, json: :created)
  end
end
