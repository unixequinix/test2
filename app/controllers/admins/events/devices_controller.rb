class Admins::Events::DevicesController < Admins::Events::BaseController
  def index
    @registrations = @current_event.device_registrations.includes(:device)
    authorize @current_event.device_registrations

    @registrations = @registrations.group_by(&:status)
  end

  def download_db # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @device = @current_event.devices.find(params[:id])
    authorize @device
    secrets = Rails.application.secrets
    credentials = Aws::Credentials.new(secrets.s3_access_key_id, secrets.s3_secret_access_key)
    s3 = Aws::S3::Resource.new(region: 'eu-west-1', credentials: credentials)
    name = "gspot/event/#{@current_event.id}/backups/#{@device.mac}"
    bucket = s3.bucket(Rails.application.secrets.s3_bucket)
    files = bucket.objects(prefix: name).collect(&:key)

    if files.any?
      zip_file = Tempfile.new(["db_backups_#{@device.mac}__", ".zip"])
      Zip::File.open(zip_file.path, Zip::File::CREATE) do |zipfile|
        files.each do |filename|
          file = Tempfile.new(@device.mac)
          bucket.object(filename).get(response_target: file.path)
          zipfile.add(filename.split("/").last, file.path)
        end
      end
      send_file zip_file.path
    else
      redirect_to request.referer, notice: "No backups Found"
    end
  end

  def show
    @device = @current_event.devices.find(params[:id])
    authorize(@device)
    @transactions = @current_event.transactions.where(device_uid: @device.mac)
    @registration = @device.device_registrations.find_by(event: @current_event)
    @device_transactions = @current_event.device_transactions.where(device_uid: @device.mac).order(:created_at)
  end
end
