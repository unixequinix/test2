class Events::SynchronousPaymentsController < Events::PaymentsBaseController
  def create
    payment_service = params[:payment_service_id]
    payer = ("Payments::#{payment_service.camelize}Payer").constantize.new
    payer.start(params, CustomerOrderCreator.new)
    redirect_to payer.action_after_payment
  end
end
