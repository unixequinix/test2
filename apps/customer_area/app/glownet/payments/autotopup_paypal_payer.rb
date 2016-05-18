class Payments::AutotopupPaypalPayer
  include Payments::AutomaticRefundable
  # TODO: Refactor method
  def start(params, customer_order_creator, customer_credit_creator)
    @event = Event.friendly.find(params[:event_id])
    @order = Order.find(params[:order_id])
    @profile = @order.profile
    @gateway = @profile.gateway_customer(EventDecorator::PAYPAL)
    @order.start_payment!
    charge_object = charge(params)
    return charge_object unless charge_object.success?
    create_agreement(charge_object, params[:autotopup_amount]) if create_agreement?(params)
    notify_payment(charge_object, customer_order_creator, customer_credit_creator)
    automatic_refund(@payment, @order.total, params[:payment_service_id])
    charge_object
  end

  def charge(params)
    begin
      charge = Braintree::Transaction.sale(options(params))
    rescue Braintree::ErrorResult
      charge
    end
    charge
  end

  private

  def options(params)
    amount = @order.total_formated
    sale_options = {
      order_id: @order.number,
      amount: amount
      customer_id: @gateway.token
    }
    submit_for_settlement(sale_options)
    vault_options(sale_options, @profile.customer) if create_agreement?(params)
    sale_options
  end

  def submit_for_settlement(sale_options)
    sale_options[:options] = {
      submit_for_settlement: true
    }
  end

  def vault_options(sale_options, customer)
    sale_options[:customer] = {
      first_name: customer.first_name,
      last_name: customer.last_name,
      email: customer.email
    }
    sale_options[:options] = {
      submit_for_settlement: true,
      store_in_vault: true
    }
  end

  def notify_payment(charge, customer_order_creator, customer_credit_creator)
    return unless charge.transaction.status == "settling"
    @payment = create_payment(@order, charge)
    @order.complete!
    send_mail_for(@order, @event)
  end

  def create_agreement(charge_object, autotopup_amount)
    customer_id = charge_object.transaction.customer_details.id
    @profile.payment_gateway_customers
            .find_or_create_by(gateway_type: EventDecorator::PAYPAL)
            .update(token: customer_id,
                    agreement_accepted: true,
                    autotopup_amount: autotopup_amount,
                    email: Braintree::Customer.find(customer_id).paypal_accounts.first.email)
    @profile.save
  end

  def create_agreement?(params)
    params[:accept] && !@profile.gateway_customer(EventDecorator::PAYPAL)
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
                    paid_at: Time.zone.at(transaction.created_at),
                    last4: transaction.credit_card_details.last_4,
                    order: order,
                    response_code: transaction.processor_response_code,
                    authorization_code: transaction.processor_authorization_code,
                    currency: @event.currency,
                    merchant_code: transaction.id,
                    amount: transaction.amount.to_f,
                    success: true,
                    payment_type: "paypal")
  end
end
