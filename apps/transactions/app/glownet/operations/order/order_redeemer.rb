class Operations::Order::OrderRedeemer < Operations::Base
  TRIGGERS = %w( record_purchase ).freeze

  def perform(atts)
    t = Order.find(atts[:id])
  end
end
