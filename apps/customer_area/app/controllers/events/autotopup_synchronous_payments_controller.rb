class Events::AutotopupSynchronousPaymentsController < Events::PaymentsBaseController
  def create
    payment_service = params[:payment_service_id]
    payer = "Payments::#{payment_service.camelize}::AutotopupPayer".constantize.new
    if payer.start(params, CustomerOrderCreator.new, CustomerCreditOrderCreator.new)
      redirect_to success_event_order_payment_service_autotopup_synchronous_payments_path(
        current_event, params[:order_id], payment_service)
    else
      redirect_to error_event_order_payment_service_autotopup_synchronous_payments_path(
        current_event, params[:order_id], payment_service)
    end
  end
end
