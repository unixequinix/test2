class Transactions::Order::OrderRedeemer < Transactions::Base
  TRIGGERS = %w( record_purchase ).freeze

  def perform(atts)
    gtag = Gtag.find_by(tag_uid: atts[:customer_tag_uid],
                        event_id: atts[:event_id],
                        activation_counter: atts[:activation_counter])

    gtag.profile.customer_orders.find_by(counter: atts[:customer_order_id])&.update!(redeemed: true)
  end
end
