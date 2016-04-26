class Events::AsynchronousPaymentsController < Events::PaymentsBaseController
  skip_before_action :authenticate_customer!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create, :success, :error]
  # TODO: Change for check credential
  skip_before_action :check_has_ticket!, only: [:create, :success, :error]

  def create
    payment_service = params[:payment_service_id]
    payer = ("Payments::#{payment_service.camelize}Payer").constantize.new
    payer.start(params, CustomerOrderCreator.new, CustomerCreditOrderCreator.new)
    render nothing: true
  end
end
