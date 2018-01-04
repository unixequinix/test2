class Admins::Events::DeviceRegistrationsController < Admins::Events::BaseController # rubocop:disable Metrics/ClassLength
  before_action :set_registration, only: %i[resolve_time show download_db destroy transactions update]
  before_action except: %i[new] do
    persist_query(%i[p q], true)
  end
  before_action :set_devices, :devices_usage, only: %i[new]

  def index
    @q = @current_event.device_registrations.ransack(params[:q])
    @registrations = @q.result.includes(:device)
    authorize @registrations
    @registrations = @registrations.group_by(&:status)
  end

  def new
    @actions = DeviceTransaction::INITIALIZATION_TYPES
    @devices_usage = devices_usage
    @device_registration = @current_event.device_registrations.new
    authorize @device_registration
  end

  def create
    devices = Device.where(id: permitted_params["device_ids"]).map do |device|
      device_registration = @current_event.device_registrations.find_or_create_by(device_id: device.id)
      authorize device_registration
      device_registration.update(allowed: false, action: permitted_params["action"])
    end

    respond_to do |format|
      if devices
        flash[:notice] = t("alerts.created")
        @devices_usage = devices_usage

        format.html { redirect_to new_admins_event_device_registration_path(@current_event) }
        format.json { render json: devices, status: :ok }
        format.js { render action: 'update_devices_usage' }
      else
        format.html { render :new }
        format.json { render json: { errors: devices.errors }, status: :unprocessable_entity }
      end
    end
  end

  def disable
    device_registrations = @current_event.device_registrations.where(device_id: permitted_params['device_ids']).map do |device_registration|
      authorize device_registration
      device_registration.update(allowed: true)
    end

    respond_to do |format|
      if !device_registrations.nil?
        flash[:notice] = t("alerts.destroyed")
        @devices_usage = devices_usage

        format.html { redirect_to request.referer }
        format.json { render json: device_registrations, status: :ok }
        format.js { render action: 'update_devices_usage' }
      else
        format.html { render :new }
        format.json { render json: { errors: device_registrations.errors }, status: :unprocessable_entity }
      end
    end
  end

  def resolve_time
    @registration.resolve_time!
    redirect_to request.referer, notice: "All timing issues solved for device #{@device.asset_tracker || 'NONE'}"
  end

  def download_db
    secrets = Rails.application.secrets
    credentials = Aws::Credentials.new(secrets.s3_access_key_id, secrets.s3_secret_access_key)
    s3 = Aws::S3::Resource.new(region: 'eu-west-1', credentials: credentials)
    name = "gspot/event/#{@current_event.id}/backups/#{@device.mac}"
    bucket = s3.bucket(Rails.application.secrets.s3_bucket)
    files = bucket.objects(prefix: name).collect(&:key)

    redirect_to(request.referer, notice: "No backups Found") && return unless files.any?

    zip_file = Tempfile.new(["db_backups_#{@device.mac}__", ".zip"])
    Zip::File.open(zip_file.path, Zip::File::CREATE) do |zipfile|
      files.each do |filename|
        file = Tempfile.new(@device.mac)
        bucket.object(filename).get(response_target: file.path)
        zipfile.add(filename.split("/").last, file.path)
      end
    end

    send_file zip_file.path
  end

  def show
    @device_transactions = @current_event.device_transactions.where(device_uid: @device.mac).order(:created_at)
    @device_stations = @current_event.transactions.where(device_uid: @device.mac).page(params[:page]).group(:station_id).count
  end

  def update
    respond_to do |format|
      if @registration.update(permitted_params)
        format.html { redirect_to new_admins_event_device_registration_path(@current_event), notice: t("alerts.updated") }
        format.json { render json: @registration }
      else
        format.html { render :new }
        format.json { render json: { errors: @device.errors }, status: :unprocessable_entity }
      end
    end
  end

  def transactions
    all_transactions = @current_event.transactions.where(device_uid: @device.mac)
    @transactions = all_transactions.includes(:station).order(:device_db_index).page(params[:page])
    @stations_count = all_transactions.select(:station_id).distinct.count
  end

  def destroy
    respond_to do |format|
      if @registration.destroy
        format.html { redirect_to admins_event_device_registrations_path, notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to [:admins, @current_event, @registration], alert: @registration.errors.full_messages.to_sentence }
        format.json { render json: { errors: @registration.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_registration
    @registration = @current_event.device_registrations.find(params[:id])
    authorize @registration
    @device = @registration.device
  end

  def set_devices
    @current_device_registrations = @current_event.device_registrations.not_allowed.includes(:device).where(devices: { team_id: @current_user&.team&.id }) # rubocop:disable Metrics/LineLength
    device_ids = @current_user.events.includes(:device_registrations).where(device_registrations: { allowed: false }).pluck(:device_id).uniq
    @available_devices = @current_user&.team&.devices&.where&.not(id: device_ids) || []

    # Search form variables
    @r = @current_device_registrations.ransack(persist_query([:p]))
    @s = @available_devices.empty? ? Device.none.ransack(persist_query([:q])) : @available_devices.search(persist_query([:q]))

    @current_device_registrations = @r.result
    @available_devices = @s.result
  end

  def persist_query(cookie_keys, clear = false) # rubocop:disable  Metrics/PerceivedComplexity
    cookie_keys.map { |key| cookies.delete(key) } && return if clear

    param = :p if cookie_keys.include?(:p)
    param = :q if cookie_keys.include?(:q)

    cookies[param] = params[param].to_json if params[param]
    params[param].presence || (cookies[param].present? && JSON.parse(cookies[param]))
  end

  def devices_usage
    @current_event.device_registrations.not_allowed.group_by { |dr| dr.device.serie }.map do |k, v|
      { k => { 'used' => v.count, 'total' => @current_event.team.devices.count } }
    end
  end

  def permitted_params
    params.require(:device_registration).permit(:action, device_ids: [])
  end
end
