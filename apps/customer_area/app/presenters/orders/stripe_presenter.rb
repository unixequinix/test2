class Orders::StripePresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
  end

  def path
    "events/orders/stripe_payment_form"
  end

  def form_data
    Payments::StripeDataRetriever.new(@event, @order)
  end
end
