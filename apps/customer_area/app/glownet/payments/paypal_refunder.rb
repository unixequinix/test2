class Payments::PaypalRefunder
  def initialize(payment, amount)
    @payment = payment
    @order = payment.order
    @amount = amount
  end

  def start
    charge_object = refund(@payment.merchant_code, @amount)
    return charge_object unless charge_object.success?
    create_payment(@order, charge_object)
    charge_object
  end

  def refund(transaction, amount)
    Braintree::Transaction.refund(transaction, amount) rescue nil
  end

  private

  def create_payment(order, charge)
    t = charge.transaction
    Payment.create!(t_type: t.payment_instrument_type,
                    card_country: t.credit_card_details.country_of_issuance,
                    paid_at: Time.at(t.created_at),
                    last4: t.credit_card_details.last_4,
                    order: order,
                    response_code: t.processor_response_code,
                    authorization_code: t.processor_authorization_code,
                    currency: order.customer_event_profile.event.currency,
                    merchant_code: t.id,
                    amount: t.amount.to_f,
                    success: true,
                    payment_type: "paypal")
  end

  def create_transaction
    @order.order_items.each do |order_item|
      obj = Operations::Base.portal_write(ActiveSupport::HashWithIndifferentAccess.new(
        fields(order_item)))
      "#{obj.class.to_s.underscore.humanize} position #{index} not valid" unless obj.valid?
    end
  end

  def fields(order_item)
    {
      event_id: @order.customer_event_profile.event_id,
      transaction_origin: "customer_portal",
      transaction_category: "refund",
      transaction_type: "refund",
      customer_tag_uid: @order.customer_event_profile.active_gtag_assignment,
      station_id: Station.joins(:station_type).find_by(
        event: order_item.order.customer_event_profile.event_id,
        station_types: { name: "customer_portal" }).id,
      catalogable_id: order_item.catalog_item.catalogable_id,
      catalogable_type: order_item.catalog_item.catalogable_type,
      items_amount: order_item.amount,
      price: order_item.total,
      payment_method: "paypal",
      payment_gateway: "paypal",
      customer_event_profile_id: @order.customer_event_profile.id,
      status_code: 0,
      status_message: "OK"
    }
  end
end
