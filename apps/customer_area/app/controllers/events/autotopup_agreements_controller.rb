class Events::AutotopupAgreementsController < Events::OrdersController
  before_action :check_autotopup!

  def new
    payment_service = params[:payment_service]
    @order = OrderCreator.autotopup_order(current_profile, current_event)
    @order_presenter =
      "Orders::#{payment_service.to_s.camelize}Presenter".constantize
                                                         .new(current_event, @order)
                                                         .with_params(params)
  end

  def update
    params[:autotopup_agreement] = true
    super
  end

  def destroy
    @payment_gateway_customer = PaymentGatewayCustomer.find(params[:id])
    if @payment_gateway_customer.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to event_url(current_event)
    else
      flash[:error] = @payment_gateway_customer.errors.full_messages.join(". ")
      redirect_to edit_event_registrations_url(current_event)
    end
  end

  private

  def check_autotopup!
    redirect_to event_url(current_event) unless current_event.gtag_assignation? &&
                                                current_profile.active_credentials? &&
                                                current_event.agreement_acceptance? &&
                                                current_event.autotopup_payment_services.present?
  end
end
