class Events::AsynchronousPaymentsController < Events::PaymentsBaseController
  skip_before_action :authenticate_customer!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_action :check_has_ticket!, only: [:create]

  def create
    payer = ("Payments::#{current_event.payment_service.camelize}Payer").constantize.new
    payer.start(params, CustomerOrderCreator.new)
    render nothing: true
  end
end
