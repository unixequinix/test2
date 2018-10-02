module Api
  module V1
    class DeviceController < Api::V1::BaseController
      skip_before_action :set_device, only: :create

      # GET /device
      def show
        render(json: @device, serializer: DeviceSerializer)
      end

      # POST /device
      def create
        @user = User.authenticate(Base64.decode64(params[:username]), Base64.decode64(params[:password]))
        render(status: :unauthorized, json: { error: "Incorrect username or password" }) && return if @user.blank?

        @team = @user&.team
        render(status: :not_found, json: { error: "User does not belong to a team" }) && return if @team.blank?

        device = @team.devices.find_by(asset_tracker: device_params[:asset_tracker])
        render(status: :conflict, json: { error: "Asset ID already in use" }) && return if device && (params[:force] == "false")

        device.update(asset_tracker: device.asset_tracker + " (replaced by #{@user.username})") if params[:force] == "true"
        device = @team.devices.create(device_params.merge(app_id: @app_id))
        render(status: :created, json: device, serializer: DeviceSerializer)
      end

      private

      def user_params
        params.require(:user).permit(:username, :password)
      end

      def device_params
        params.require(:device).permit(:asset_tracker, :imei, :mac, :serial, :manufacturer, :device_model, :android_version, extra_info: {})
      end
    end
  end
end
