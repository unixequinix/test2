class Orders::BraintreePresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
  end

  def path
    "events/orders/braintree_payment_form"
  end

  def form_data
    Payments::BraintreeDataRetriever.new(@event, @order)
  end
end
