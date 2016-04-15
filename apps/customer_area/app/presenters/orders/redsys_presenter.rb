class Orders::RedsysPresenter < Orders::BasePresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
  end

  def path
    "events/orders/redsys/payment_form"
  end

  def payment_service
    "redsys"
  end
end
