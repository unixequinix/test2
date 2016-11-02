class Payments::Braintree::DataRetriever < Payments::BaseDataRetriever
  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order, :client_token

  def initialize(event, order)
    @current_event = event
    @order = order
    @payment_parameters = Parameter.joins(:event_parameters)
                                   .where(category: "payment",
                                          group: "braintree",
                                          event_parameters: { event: event })
                                   .select("parameters.name, event_parameters.*")
    Braintree::Configuration.environment = environment
    Braintree::Configuration.merchant_id = merchant_id
    Braintree::Configuration.public_key = public_key
    Braintree::Configuration.private_key = private_key
    @client_token = generate_client_token
  end

  private

  def generate_client_token
    Braintree::ClientToken.generate
  end

  def environment
    get_value_of_parameter("environment")
  end

  def merchant_id
    get_value_of_parameter("merchant_id")
  end

  def public_key
    get_value_of_parameter("public_key")
  end

  def private_key
    get_value_of_parameter("private_key")
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.value
  end
end
