class Orders::RedsysPresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
  end

  def path
    "events/orders/redsys_payment_redirection"
  end

  def payment_service
    "redsys"
  end
end
