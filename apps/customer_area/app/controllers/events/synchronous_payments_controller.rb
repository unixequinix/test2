class Events::SynchronousPaymentsController < Events::PaymentsBaseController
  def create
    payer = ("Payments::#{current_event.payment_service.camelize}Payer").constantize.new
    payer.start(params, CustomerOrderCreator.new)
    redirect_to payer.action_after_payment
  end
end
