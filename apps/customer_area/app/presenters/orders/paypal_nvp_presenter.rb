class Orders::PaypalNvpPresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
  end

  def path
    "events/orders/paypal_nvp_payment_redirection"
  end

  def form_data
    Payments::PaypalNvpDataRetriever.new(@event, @order)
  end

  def payment_service
    "paypal_nvp"
  end
end
