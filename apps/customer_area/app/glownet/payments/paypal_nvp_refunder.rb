class Payments::PaypalNvpRefunder
  def initialize(payment, amount)
    @payment = payment
    @order = payment.order
    @amount = amount
  end

  def start
    charge_object = refund(@payment.merchant_code, @amount)
    return charge_object unless charge_object.success?
    create_payment(@order, charge_object)
    create_transaction
    charge_object
  end

  def refund(transaction, amount)
    refund_transaction(transaction, amount)
  end

  def refund_transaction(transaction, _amount)
    params = {
      "METHOD" => "RefundTransaction",
      "USER" => get_value_of_parameter("user"),
      "PWD" => get_value_of_parameter("password"),
      "SIGNATURE" => get_value_of_parameter("signature"),
      "VERSION" => "86",
      "TRANSACTIONID" => transaction,
      "REFUNDTYPE" => "Full"
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map { |it| it.split("=") }.to_h
  end

  private

  def create_payment(order, charge)
    transaction = charge.transaction
    Payment.create!(transaction_type: transaction.payment_instrument_type,
                    card_country: transaction.credit_card_details.country_of_issuance,
                    paid_at: Time.at(transaction.created_at),
                    last4: transaction.credit_card_details.last_4,
                    order: order,
                    response_code: transaction.processor_response_code,
                    authorization_code: transaction.processor_authorization_code,
                    currency: order.customer_event_profile.event.currency,
                    merchant_code: transaction.id,
                    amount: transaction.amount.to_f,
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
