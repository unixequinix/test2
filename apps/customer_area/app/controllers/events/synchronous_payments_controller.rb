class Events::SynchronousPaymentsController < Events::PaymentsBaseController
  def create
    payment_service = params[:payment_service_id]
    payer = "Payments::#{payment_service.camelize}::Payer".constantize.new(params)
    if payer.start(CustomerOrderCreator.new, CreditWriter)
      redirect_to success_event_order_payment_service_synchronous_payments_path(
        current_event, params[:order_id], payment_service
      )
    else
      redirect_to error_event_order_payment_service_synchronous_payments_path(
        current_event, params[:order_id], payment_service
      )
    end
  end
end
