class Transactions::Order::OrderRedeemer < Transactions::Base
  TRIGGERS = %w[order_redeemed].freeze

  def perform(atts)
    gtag = Gtag.find(atts[:gtag_id])
    gtag.customer.order_items.find_by(counter: atts[:order_item_counter]).update!(redeemed: true)
    gtag.customer.touch
  end
end
