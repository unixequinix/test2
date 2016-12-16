class Transactions::Order::OrderRedeemer < Transactions::Base
  TRIGGERS = %w( order_redeemed ).freeze

  def perform(atts)
    tag = { tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id], activation_counter: atts[:activation_counter] }
    gtag = Gtag.find_by(tag)
    gtag.customer.order_items.find_by_counter(atts[:order_item_counter]).update!(redeemed: true)
  end
end
