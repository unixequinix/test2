class Api::V1::Events::DatabasesController < Api::V1::Events::BaseController
  def show
    category = permitted_params[:basic].eql?("true") ? "basic" : "full"
    app_version = permitted_params[:app_version] || 'unknown'

    device_cache = @current_event.device_caches.find_by(category: category, app_version: app_version)

    render(status: :not_found, json: :not_found) && return unless device_cache

    render(json: { url: AwsManager.generate_url(device_cache.file.path) })
  end

  def create
    file = permitted_params[:file]
    render(status: :bad_request, json: { errors: "File empty" }) && return unless file

    atts = {}
    atts[:app_version] = permitted_params[:app_version] || 'unknown'
    atts[:category] = permitted_params[:basic].eql?("true") ? "basic" : "full"

    device_cache = @current_event.device_caches.find_or_initialize_by(atts)
    device_cache.file = file

    render(status: :created, json: :created) && return if device_cache.save
    render(status: :unprocessable_entity, json: { errors: device_cache.errors })
  end

  private

  def permitted_params
    params.permit(:file, :basic, :app_version, :format, :event_id)
  end
end
