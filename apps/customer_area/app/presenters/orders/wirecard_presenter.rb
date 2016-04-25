class Orders::WirecardPresenter < Orders::BasePresenter
  attr_accessor :event, :order, :storage_id, :javascript_url

  def initialize(event, order)
    @event = event
    @order = order
  end

  def path
    "events/orders/wirecard/payment_form"
  end

  def form_data
    Payments::WirecardDataRetriever.new(@event, @order)
  end

  def payment_service
    "wirecard"
  end
end
