class Orders::IdealPresenter < Orders::BasePresenter
  attr_accessor :event, :order, :storage_id, :javascript_url

  def initialize(event, order)
    @event = event
    @order = order
  end

  def path
    "events/orders/ideal/payment_form"
  end

  def form_data
    Payments::IdealDataRetriever.new(@event, @order)
  end

  def payment_service
    "ideal"
  end

  def banks
    [
      ["ABN AMRO Bank", "ABNAMROBANK"],
      ["ASN Bank", "ASNBANK"],
      ["ING", "INGBANK"],
      ["knab", "KNAB"],
      ["Rabobank", "RABOBANK"],
      ["SNS Bank", "SNSBANK"],
      ["RegioBank", "REGIOBANK"],
      ["Triodos Bank", "TRIODOSBANK"],
      ["Van Lanschot Bankiers", "VANLANSCHOT"]
    ]
  end
end
