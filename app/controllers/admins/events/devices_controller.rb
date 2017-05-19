class Admins::Events::DevicesController < Admins::Events::BaseController
  # rubocop:disable all
  def index
    pack_names = %w(pack_device lock_device)
    authorize @current_event.devices

    @devices = @current_event.devices.each do |device|
      device_transactions = @current_event.device_transactions.where(device: device)
      last = device_transactions.order(:created_at).last

      ts = @current_event.transactions.onsite.where(device_uid: device.mac)
      ts = ts.where("device_created_at <= ?", last.created_at.to_formatted_s(:transactions)) if last
      count = ts.count
      last_onsite = ts.order(:device_created_at).last


      status = if last
        last_action = device_transactions.where.not(action: "DEVICE_REPORT").order(:created_at).last.action.downcase
        device.action = last_action
        last_transactions_count = last.number_of_transactions.to_i
        case
          when (count != last_transactions_count) then
            count_diff = last_transactions_count - count
            device.msg = "+#{count_diff.abs} in #{count_diff.positive? ? 'Device' : 'Server'}"
            "to_check"
          when count.zero? && last_transactions_count.zero? then "unused"
          when last_action.eql?("device_initialization") then "live"
          when last_action.in?(pack_names) then "locked"
          else "no_idea"
        end
      else
       "unused"
      end

      device.live = last_onsite.created_at > 5.minute.ago if last_onsite
      device.live = last.created_at > 5.minute.ago if last
      device.live_time = last_onsite.created_at if last_onsite
      device.live_time = last.created_at if last
      device.number_of_transactions = last&.number_of_transactions.to_i
      device.server_transactions = count
      device.status = status
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
    @device_transactions = @current_event.device_transactions.where(device_uid: @device.mac).order(:created_at)
  end
end
