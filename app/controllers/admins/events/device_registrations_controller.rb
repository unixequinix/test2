module Admins
  module Events
    class DeviceRegistrationsController < Admins::Events::BaseController
      before_action :set_registration, only: %i[show download_db destroy transactions update]
      before_action do
        persist_query(%i[p q], true)
      end
      before_action :set_devices, :devices_usage, only: %i[index]
      before_action :set_device_registration_actions, only: %i[index create disable]

      def index
        @q = @current_event.device_registrations.ransack(params[:q])
        @registrations = @q.result.includes(:device)
        authorize @registrations

        @device_caches = @current_event.device_caches
        @devices_usage = devices_usage
        @registrations = @registrations.group_by(&:status)
      end

      def create
        message = t("alerts.created")
        message_style = :notice

        devices = Device.where(id: permitted_params["device_ids"]).map do |device|
          if device.device_registrations.where(allowed: false).none?
            device_registration = @current_event.device_registrations.find_or_create_by(device_id: device.id)
            authorize device_registration
            initialization_type = params[:device_registration][:action] || permitted_params["initialization_type"].presence || @actions.first.to_s
            device_registration.update(allowed: false, initialization_type: initialization_type)
          else
            skip_authorization
            message = "Unable to add the device. Device already belongs to another event."
            message_style = :alert
          end
        end

        respond_to do |format|
          if devices
            flash[message_style] = message
            @devices_usage = devices_usage
            set_devices

            format.html { redirect_to admins_event_device_registrations_path(@current_event) }
            format.json { render json: devices, status: :ok }
            format.js { render action: 'update_devices_usage' }
          else
            format.html { render :index }
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
            set_devices

            format.html { redirect_to admins_event_device_registrations_path(@current_event) }
            format.json { render json: device_registrations, status: :ok }
            format.js { render action: 'update_devices_usage' }
          else
            format.html { render :index }
            format.json { render json: { errors: device_registrations.errors }, status: :unprocessable_entity }
          end
        end
      end

      def download_db
        secrets = Rails.application.secrets
        credentials = Aws::Credentials.new(secrets.s3_access_key_id, secrets.s3_secret_access_key)
        s3 = Aws::S3::Resource.new(region: 'eu-west-1', credentials: credentials)
        name = "gspot/event/#{@current_event.id}/backups/#{@device.id}"
        bucket = s3.bucket(Rails.application.secrets.s3_bucket)
        files = bucket.objects(prefix: name).collect(&:key)

        redirect_to(request.referer, notice: "No backups Found") && return unless files.any?

        zip_file = Tempfile.new(["db_backups_#{@device.id}__", ".zip"])
        Zip::File.open(zip_file.path, Zip::File::CREATE) do |zipfile|
          files.each do |filename|
            file = Tempfile.new("temp_backupfile_#{@device.id}_")
            bucket.object(filename).get(response_target: file.path)
            zipfile.add(filename.split("/").last, file.path)
          end
        end

        send_file zip_file.path
      end

      def show
        @device_transactions = @current_event.device_transactions.where(device: @device).order(:created_at)
        @device_stations = @current_event.transactions.where(device: @device).page(params[:page]).group(:station_id).count
        @registration.load_last_results
      end

      def update
        respond_to do |format|
          if @registration.update(permitted_params)
            format.html { redirect_to admins_event_device_registrations_path(@current_event), notice: t("alerts.updated") }
            format.json { render json: @registration }
          else
            format.html { render :index }
            format.json { render json: { errors: @device.errors }, status: :unprocessable_entity }
          end
        end
      end

      def transactions
        all_transactions = @current_event.transactions.where(device: @device)
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

      def set_device_registration_actions
        @actions = DeviceTransaction::INITIALIZATION_TYPES
      end

      def set_devices
        @device_registration = @current_event.device_registrations.new
        @current_device_registrations = @current_event.device_registrations.not_allowed.joins(:device).where(devices: { team_id: @current_user&.team&.id })

        device_ids = @current_user&.team&.devices&.includes(:device_registrations)&.where(device_registrations: { allowed: false })&.pluck(:id)
        @available_devices = @current_user&.team&.devices&.where&.not(id: device_ids) || []

        # Search form variables
        @r = @current_device_registrations.ransack(persist_query([:p]))
        @s = @available_devices.empty? ? Device.none.ransack(persist_query([:q])) : @available_devices.search(persist_query([:q]))
        
        @current_device_registrations = @r.result.page(params[:devicesin])
        @available_devices = @s.result.page(params[:devicesout])
      end

      def persist_query(cookie_keys, clear = false) # rubocop:disable  Metrics/PerceivedComplexity
        cookie_keys.map { |key| cookies.delete(key) } && return if clear

        param = :p if cookie_keys.include?(:p)
        param = :q if cookie_keys.include?(:q)

        cookies[param] = params[param].to_json if params[param]
        params[param].presence || (cookies[param].present? && JSON.parse(cookies[param]))
      end

      def devices_usage
        @current_event.device_registrations.not_allowed.includes(:device).group_by { |dr| dr.device.serie }.map do |k, v|
          { k => { 'used' => v.count, 'total' => @current_user&.team&.devices&.count } }
        end
      end

      def permitted_params
        params.require(:device_registration).permit(:initialization_type, device_ids: [])
      end
    end
  end
end
