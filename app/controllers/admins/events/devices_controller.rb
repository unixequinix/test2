class Admins::Events::DevicesController < Admins::Events::BaseController
  # rubocop:disable all
  def index
    pack_names = %w(pack_device lock_device)
    authorize @current_event.devices

    @devices = @current_event.devices.each do |device|
      device_transactions = @current_event.device_transactions.where(device: device)
      registration = device.device_registrations.find_by(event: @current_event)
      count = registration.server_transactions
      last_onsite = @current_event.transactions.onsite.where(device_uid: device.mac).order(:device_created_at).last

      last_action = device_transactions.order(:created_at).last&.action&.downcase&.to_s
      device.action = last_action
      last_transactions_count = registration.number_of_transactions
      device.status = case
        when (count != last_transactions_count) then
          count_diff = last_transactions_count - count
          device.msg = "+#{count_diff.abs} in #{count_diff.positive? ? 'Device' : 'Server'}"
          "to_check"
        when last_action.in?(pack_names) then "locked"
        when count.zero? && last_transactions_count.zero? then "staged"
        when last_action.eql?("device_initialization") then "live"
        else "no_idea"
      end


      device.live = last_onsite.created_at > 5.minute.ago if last_onsite
      device.live = registration.updated_at > 5.minute.ago
      device.live_time = last_onsite.created_at if last_onsite
      device.live_time = registration.updated_at
      device.battery = registration.battery
      device.number_of_transactions = registration.number_of_transactions
      device.server_transactions = registration.server_transactions
      device.operator = last_onsite&.operator_tag_uid
      device.station = last_onsite&.station&.name
      device.last_time_used = last_onsite&.device_created_at
    end.group_by(&:status)
  end

  def download_db
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
