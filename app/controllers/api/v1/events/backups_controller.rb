class Api::V1::Events::BackupsController < Api::V1::Events::BaseController
  skip_before_action :restrict_app_version

  def create
    keys = %i[device_uid backup_created_at backup].any? { |i| params[i] }

    secrets = Rails.application.secrets
    credentials = Aws::Credentials.new(secrets.s3_access_key_id, secrets.s3_secret_access_key)
    s3 = Aws::S3::Resource.new(region: 'eu-west-1', credentials: credentials)

    device = params[:device_uid].delete("\"")
    time = Time.parse(params[:backup_created_at]).to_i
    name = "gspot/event/#{params[:event_id]}/backups/#{device}/#{time}.db"
    obj = s3.bucket(Rails.application.secrets.s3_bucket).object(name)
    obj.put(body: params[:backup])

    render(status: :bad_request, json: { error: "params missing" }) && return unless keys
    render(status: :created, json: :created)
  end
end
