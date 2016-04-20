class Orders::SofortPresenter < Orders::BasePresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
  end

  def path
    "events/orders/sofort/payment_form"
  end

  def form_data
    Payments::SofortDataRetriever.new(@event, @order)
  end

  def payment_service
    "braintree"
  end
end
