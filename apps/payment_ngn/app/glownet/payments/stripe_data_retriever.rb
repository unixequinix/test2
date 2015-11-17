class Payments::StripeDataRetriever
  include Rails.application.routes.url_helpers
  attr_reader :current_event

  def initialize(event, order)
    @current_event = event
    @order = order
    @payment_parameters = Parameter.joins(:event_parameters).where(category: "payment", group: @current_event.payment_service, event_parameters: {event: event}).select("parameters.name, event_parameters.*")
  end

  def name
    get_value_of_parameter("name")
  end

  def key
    get_value_of_parameter("key")
  end


  private

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.value
  end
end