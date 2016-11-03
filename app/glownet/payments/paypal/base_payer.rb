class Payments::Paypal::BasePayer
  def initialize(params)
    @event = Event.friendly.find(params[:event_id])
    @order = Order.find(params[:order_id])
    @profile = @order.profile
    @gateway = @profile.gateway_customer(EventDecorator::PAYPAL)
    @method = @gateway ? "auto" : "regular"
    @params = params
  end

  def charge
    begin
      charge = Braintree::Transaction.sale(options)
    rescue Braintree::ErrorResult
      charge
    end
    charge
  end

  private

  def options
    amount = @order.total_formated
    sale_options = {
      order_id: @order.number,
      amount: amount
    }
    submit_for_settlement(sale_options)
    vault_options(sale_options, @profile.customer) if create_agreement?
    send("#{@method}_payment_options", sale_options)
    sale_options
  end

  def submit_for_settlement(sale_options)
    sale_options[:options] = {
      submit_for_settlement: true
    }
  end

  def regular_payment_options(sale_options)
    sale_options[:payment_method_nonce] = @params[:payment_method_nonce]
  end

  def auto_payment_options(sale_options)
    sale_options[:customer_id] = @gateway.token
  end

  def vault_options(sale_options, customer)
    sale_options[:customer] = {
      first_name: customer.first_name, last_name: customer.last_name, email: customer.email
    }
    sale_options[:options] = {
      submit_for_settlement: true, store_in_vault: true
    }
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

  def create_agreement?
    @params[:accept] && !@profile.gateway_customer(EventDecorator::PAYPAL)
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