class Admins::Events::DeviceSettingsController < Admins::Events::BaseController
  def show # rubocop:disable Metrics/AbcSize
    @event = current_event
    s3 = AWS::S3.new(access_key_id: Rails.application.secrets.s3_access_key_id,
                     secret_access_key: Rails.application.secrets.s3_secret_access_key)
    bucket = s3.buckets[Rails.application.secrets.s3_bucket]

    basic_db = bucket.objects[@event.device_basic_db.path]
    full_db = bucket.objects[@event.device_full_db.path]

    msg = t("admin.event.databases.not_found")
    @basic_db_created_at = basic_db.key.blank? ? msg : basic_db.last_modified.to_formatted_s(:db)
    @full_db_created_at = full_db.key.blank? ? msg : full_db.last_modified.to_formatted_s(:db)

    @event_parameters = @fetcher.device_general_parameters
  end

  def edit
    @event = current_event
    @device_settings_form = DeviceSettingsForm.new
    event_parameters = @fetcher.device_general_parameters

    event_parameters.each do |event_parameter|
      @device_settings_form[event_parameter.parameter.name.to_sym] = event_parameter.value
    end
  end

  def update
    @event = Event.friendly.find(params[:event_id])
    @device_settings_form = DeviceSettingsForm.new(permitted_params)

    if @device_settings_form.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_device_settings_url(@event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  private

  def permitted_params
    params_names = Parameter.where(category: "device", group: "general").map(&:name)
    params_names << :event_id
    params.require("device_settings_form").permit(params_names)
  end
end
