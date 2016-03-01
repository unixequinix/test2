class Admins::Events::GtagKeysController < Admins::Events::BaseController
  def show
    @event = current_event
    @event_parameters = @fetcher.event_parameters
                        .where(parameters: { group: gtag_type, category: "gtag" })
                        .includes(:parameter)
  end

  def edit
    @event = current_event
    @gtag_type = gtag_type
    @gtag_keys_form = "#{gtag_type}_form".classify.constantize.new
    event_parameters = @fetcher.event_parameters
                       .where(parameters: { group: gtag_type, category: "gtag" })
                       .includes(:parameter)

    event_parameters.each do |event_parameter|
      @gtag_keys_form[event_parameter.parameter.name.to_sym] = event_parameter.value
    end
  end

  def update
    @gtag_type = gtag_type
    @gtag_keys_form = "#{gtag_type}_form".classify.constantize.new(permitted_params)

    if @gtag_keys_form.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_gtag_keys_url(current_event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  private

  def gtag_type
    current_event.get_parameter("gtag", "form", "gtag_type")
  end

  def permitted_params
    params_names = Parameter.where(category: "gtag", group: gtag_type).map(&:name)
    params_names << :event_id
    params.require("#{gtag_type}_form").permit(params_names)
  end
end
