class Events::SynchronousPaymentsController < Events::PaymentsBaseController
  def create
    payment_service = params[:payment_service_id]
    payer = "Payments::#{payment_service.camelize}::Payer".constantize.new(params)
    route_atts = [current_event, params[:order_id], payment_service]
    charge = payer.start(CustomerOrderCreator.new, CreditWriter)
    if charge.try(:status).eql?("succeeded")
      redirect_to success_event_order_payment_service_synchronous_payments_path(*route_atts)
    else
      redirect_to error_event_order_payment_service_synchronous_payments_path(*route_atts)
    end
  end
end
