class Payments::BraintreeRefunder
  def start(params)
    @event = Event.friendly.find(params[:event_id])
    @order = Order.find(params[:order_id])
    @order.start_payment!
    charge_object = charge(params)
    return charge_object unless charge_object.success?
    notify_payment(charge_object, customer_order_creator, customer_credit_creator)
    charge_object
  end

  def refund(_params, amount)
    begin
      charge = Braintree::Transaction.refund("j59qrb", amount)
    rescue Braintree::ErrorResult
      # The card has been declined
      charge
    end
    charge
  end

  private

  def options(params)
    token = params[:payment_method_nonce]
    amount = @order.total_formated
    sale_options = {
      order_id: @order.number,
      amount: amount,
      payment_method_nonce: token
    }
    sale_options
  end

  def notify_refund(charge, _customer_order_creator, _customer_credit_creator)
    transaction = charge.transaction
    return unless transaction.status == "authorized"
    # create_payment(@order, charge)
    @order.complete!
    create_transaction

    send_mail_for(@order, @event)
  end

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end

  def get_event_parameter_value(event, name)
    EventParameter.find_by(event_id: event.id,
                           parameter: Parameter.where(category: "payment",
                                                      group: "braintree",
                                                      name: name)).value
  end

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
                    payment_type: "braintree")
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
      event_id: @event.id,
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
      payment_method: "card",
      payment_gateway: "braintree",
      customer_event_profile_id: @order.customer_event_profile.id,
      status_code: 0,
      status_message: "OK"
    }
  end
end
