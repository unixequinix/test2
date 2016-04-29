class Payments::RedsysDataRetriever < Payments::BaseDataRetriever
  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order

  def initialize(event, order)
    @current_event = event
    @order = order
    @payment_parameters = Parameter.joins(:event_parameters)
                          .where(category: "payment",
                                 group: "redsys",
                                 event_parameters: { event: event })
                          .select("parameters.name, event_parameters.*")
  end

  def amount
    (@order.total * 100).floor
  end

  def form
    get_value_of_parameter("form")
  end

  def name
    get_value_of_parameter("name")
  end

  def code
    get_value_of_parameter("code")
  end

  def terminal
    get_value_of_parameter("terminal")
  end

  def currency
    get_value_of_parameter("currency")
  end

  def transaction_type
    get_value_of_parameter("transaction_type")
  end

  def password
    get_value_of_parameter("password")
  end

  def pay_methods
    "0"
  end

  def product_description
    @current_event.name
  end

  def client_name
    @order.profile.customer.first_name
  end

  def notification_url
    event_order_payment_service_asynchronous_payments_url(@current_event, @order, "redsys")
  end

  def message
    "#{amount}#{@order.number}#{code}#{currency}#{transaction_type}#{notification_url}#{password}"
  end

  def signature
    Digest::SHA1.hexdigest(message).upcase
  end

  private

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.value
  end
end
