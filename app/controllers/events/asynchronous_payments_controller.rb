class Events::AsynchronousPaymentsController < Events::PaymentsBaseController
  skip_before_action :authenticate_customer!, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create, :success, :error]
  # TODO: Change for check credential
  skip_before_action :check_has_ticket!, only: [:create, :success, :error]

  def create
    payment_service = params[:payment_service_id]
    payer = "Payments::#{payment_service.camelize}::Payer".constantize.new(params)
    payer.start(CustomerOrderCreator.new, CreditWriter)
    render nothing: true
  end
end
