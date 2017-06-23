class Admins::Events::DeviceRegistrationsController < Admins::Events::BaseController
  before_action :set_registration, only: %i[resolve_time show download_db destroy]

  def index
    @registrations = @current_event.device_registrations.includes(:device)
    authorize @current_event.device_registrations
    @registrations = @registrations.group_by(&:status)
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
    @transactions = @current_event.transactions.where(device_uid: @device.mac).includes(:gtag, :station).order(:device_db_index).page(params[:page])
    @device_transactions = @current_event.device_transactions.where(device_uid: @device.mac).order(:created_at)
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
end
