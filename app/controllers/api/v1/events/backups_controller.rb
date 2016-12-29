class Api::V1::Events::BackupsController < Api::V1::Events::BaseController
  def create
    keys = [:device_uid, :backup_created_at, :backup].any? { |i| params[i] }

    secrets = Rails.application.secrets
    credentials = Aws::Credentials.new(secrets.s3_access_key_id, secrets.s3_secret_access_key)
    s3 = Aws::S3::Resource.new(region:'eu-west-1', credentials: credentials)

    time = Time.parse(params[:backup_created_at]).to_i
    name = "/gspot/event/#{params[:event_id]}/backups/#{params[:device_uid]}/#{params[:device_uid]}-#{time}"
    obj = s3.bucket(Rails.application.secrets.s3_bucket).object(name)

    obj.upload_file(File.read(params[:backup].tempfile))

    render(status: :bad_request, json: { error: "params missing" }) && return unless keys
    render(status: :created, json: :created)
  end
end
