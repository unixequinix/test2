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

  def storage_id
    form_data.data_storage["storageId"]
  end

  def javascript_url
    form_data.data_storage["javascriptUrl"]
  end

end
