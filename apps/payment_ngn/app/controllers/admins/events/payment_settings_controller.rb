class Admins::Events::PaymentSettingsController < Admins::Events::BaseController
  def show
    @event = Event.friendly.find(params[:event_id])
    @event_parameters = @fetcher.event_parameters.where(parameters: { group: @event.payment_service,
                                                                      category: "payment" })
                                                 .includes(:parameter)
  end

  def new
    @event = Event.friendly.find(params[:event_id])
    @fetcher.event_parameters.find_by(parameter: Parameter.where(group: @event.payment_service,
                                                                 category: "payment",
                                                                 name: "stripe_account_id"))
    @parameters = Parameter.where(group: @event.payment_service, category: "payment")
    @payment_settings_form = ("#{@event.payment_service.camelize}PaymentSettingsForm")
                             .constantize.new
  end

  def create
    @event = Event.friendly.find(params[:event_id])
    @parameters = Parameter.where(group: @event.payment_service, category: "payment")
    @payment_settings_form = ("#{@event.payment_service.camelize}PaymentSettingsForm")
                             .constantize.new(permitted_params)
    if @payment_settings_form.save(params, request)
      @event.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_payment_settings_url(@event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def edit
    @event = Event.friendly.find(params[:event_id])
    @parameters = Parameter.where(group: @event.payment_service, category: "payment")
    event_parameters = @fetcher.event_parameters.where(parameters: { group: @event.payment_service,
                                                                     category: "payment" })
                                                .joins(:parameter)
                                                .select("parameters.name, event_parameters.value")
                                                .as_json
    total = event_parameters.reduce({}) { |a, e| a.merge(e["name"] => e["value"]) }
    @payment_settings_form = ("#{@event.payment_service.camelize}PaymentSettingsForm")
                             .constantize.new(total)
  end

  def update
    @event = Event.friendly.find(params[:event_id])
    @parameters = Parameter.where(group: @event.payment_service, category: "payment")
    @payment_settings_form = ("#{@event.payment_service.camelize}PaymentSettingsForm")
                             .constantize.new(permitted_params)
    if @payment_settings_form.update
      @event.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_payment_settings_url(@event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  private

  def permitted_params
    params_names = Parameter.where(group: current_event.payment_service, category: "payment")
                            .map(&:name)
    params_names << :event_id
    params.require("#{current_event.payment_service}_payment_settings_form").permit(params_names)
  end
end
