class Orders::WirecardPresenter < Orders::BasePresenter
  attr_accessor :event, :order, :storage_id, :javascript_url

  def initialize(event, order)
    @event = event
    @order = order
    @form_data = Payments::Wirecard::DataRetriever.new(@event, @order)
  end

  def path
    "events/orders/wirecard/payment_form"
  end

  def payment_service
    "wirecard"
  end

  def storage_id
    @form_data.data_storage_id
  end

  def javascript_url
    @form_data.data_storage_javascript_url
  end
end
