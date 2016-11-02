class Orders::BraintreePresenter < Orders::BasePresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
  end

  def path
    "events/orders/braintree/payment_form"
  end

  def form_data
    Payments::Braintree::DataRetriever.new(@event, @order)
  end

  def payment_service
    "braintree"
  end
end
