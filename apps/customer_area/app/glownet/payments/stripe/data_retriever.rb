class Payments::Stripe::DataRetriever < Payments::BaseDataRetriever
  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order

  def initialize(event, order)
    @current_event = event
    @order = order
    @payment_parameters = Parameter.joins(:event_parameters)
                                   .where(category: "payment",
                                          group: "stripe",
                                          event_parameters: { event: event })
                                   .select("parameters.name, event_parameters.*")
  end

  def name
    get_value_of_parameter("name")
  end

  def stripe_account_id
    get_value_of_parameter("stripe_account_id")
  end

  def email
    get_value_of_parameter("email")
  end

  def country
    get_value_of_parameter("country")
  end

  def platform_secret_key
    get_value_of_parameter("platform_secret_key")
  end

  def account_secret_key
    get_value_of_parameter("account_secret_key")
  end

  def account_publishable_key
    get_value_of_parameter("account_publishable_key")
  end

  private

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.value
  end
end
