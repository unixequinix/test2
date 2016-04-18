class Payments::BraintreePayer
  def start(params, customer_order_creator, customer_credit_creator)
    @event = Event.friendly.find(params[:event_id])
    @order = Order.find(params[:order_id])
    @order.start_payment!
    charge_object = charge(params)
    return charge_object unless charge_object.success?
    notify_payment(charge_object, customer_order_creator, customer_credit_creator)
    charge_object
  end

  def charge(params)
    begin
      charge = Braintree::Transaction.sale(options(params))
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
    submit_for_settlement(sale_options)
    sale_options
  end

  def submit_for_settlement(sale_options)
    sale_options[:options] = {
      submit_for_settlement: true
    }
  end

  def notify_payment(charge, customer_order_creator, customer_credit_creator)
    transaction = charge.transaction
    return unless transaction.status == "submitted_for_settlement"
    customer_credit_creator.save(@order)
    create_payment(@order, charge)
    customer_order_creator.save(@order)
    create_money_transaction(fields)
    @order.complete!
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

  def create_money_transaction(fields)
    binding.pry
    obj = Operations::Base.portal_write(ActiveSupport::HashWithIndifferentAccess.new(fields))
    "#{obj.class.to_s.underscore.humanize} position #{index} not valid" unless obj.valid?
  end

  def fields
    { event_id: 1,
      transaction_origin: "Money",
      transaction_category: "Money",
      transaction_type: "Money",
      customer_tag_uid: nil,
      station_id: 12,
      catalogable_id: 12,
      catalogable_type: 12,
      items_amount: 12,
      price: 12,
      payment_method: 12,
      payment_gateway: 12,
      customer_event_profile_id: nil,
      status_code: 12,
      status_message: 12
    }

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
end
