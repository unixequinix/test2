class Admins::Events::GtagSettingsController < Admins::Events::BaseController
  def show
    @event = current_event
    @event_parameters =
      @fetcher.event_parameters.where(parameters: { group: "form", category: "gtag" })
                               .includes(:parameter)
  end

  def edit
    # TODO: Try to initialize the gtag settings form
    @event = current_event
    @parameters = Parameter.where(group: "form", category: "gtag")
    @gtag_settings_form = GtagSettingsForm.new
    event_parameters =
      @fetcher.event_parameters.where(parameters: { group: "form", category: "gtag" })
                               .includes(:parameter)
    event_parameters.each do |event_parameter|
      @gtag_settings_form[event_parameter.parameter.name.to_sym] = event_parameter.value
    end
    @gtag_settings_form[:gtag_name] = @event.gtag_name
    @gtag_settings_form[:gtag_form_disclaimer] = @event.gtag_form_disclaimer
    @gtag_settings_form[:gtag_assignation_notification] = @event.gtag_assignation_notification
  end

  def update
    @event = Event.friendly.find(params[:event_id])
    @parameters = Parameter.where(group: "form", category: "gtag")
    @gtag_settings_form = GtagSettingsForm.new(permitted_params)
    if @gtag_settings_form.save
      @event.gtag_name = permitted_params[:gtag_name]
      @event.gtag_form_disclaimer = permitted_params[:gtag_form_disclaimer]
      @event.gtag_assignation_notification = permitted_params[:gtag_assignation_notification]
      @event.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_gtag_settings_url(@event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  private

  def permitted_params
    params_names = Parameter.where(group: "form", category: "gtag").map(&:name)
    params_names << :event_id
    params_names << :gtag_name
    params_names << :gtag_form_disclaimer
    params_names << :gtag_assignation_notification
    params.require("gtag_settings_form").permit(params_names)
  end
end
