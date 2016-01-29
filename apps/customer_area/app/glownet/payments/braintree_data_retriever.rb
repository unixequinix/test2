class Payments::BraintreeDataRetriever
  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order, :client_token

  def initialize(event, order)
    @current_event = event
    @order = order
    @payment_parameters = Parameter.joins(:event_parameters)
                                   .where(category: "payment",
                                          group: @current_event.payment_service,
                                          event_parameters: { event: event })
                                   .select("parameters.name, event_parameters.*")
    Braintree::Configuration.environment  = :sandbox
    Braintree::Configuration.merchant_id   = 'ggtbw7zbswh382kw'
    Braintree::Configuration.public_key   = 'xgbtvr7dnsgddgpq'
    Braintree::Configuration.private_key  = '2d008acc70e917328fd6161ffa92c021'
    @client_token = generate_client_token
  end

  private

  def generate_client_token
    customer_event_profile = order.customer_event_profile
    gateway_customer =
      customer_event_profile.payment_gateway_customers.find_by(gateway_type: Event::BRAINTREE)
    if gateway_customer
      Braintree::ClientToken.generate(customer_id: gateway_customer.token)
    else
      Braintree::ClientToken.generate
    end
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.value
  end
end
