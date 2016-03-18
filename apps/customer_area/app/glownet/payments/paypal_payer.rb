class Payments::PaypalPayer
  include Rails.application.routes.url_helpers
  attr_reader :action_after_payment

  def initialize
    @action_after_payment = ""
  end

  def start(params, customer_order_creator, customer_credit_creator)
    @event = Event.friendly.find(params[:event_id])
    @order = Order.find(params[:order_id])
    @order.start_payment!
    charge_object = charge(params)
    if charge_object.success?
      notify_payment(charge_object, customer_order_creator, customer_credit_creator)
      @action_after_payment =
        success_event_order_payment_service_synchronous_payments_path(@event, @order, "braintree")
    else
      @action_after_payment =
        error_event_order_payment_service_synchronous_payments_path(@event, @order, "braintree")
    end
  end

  def charge(params)
    begin
      charge = Braintree::Transaction.sale(sale_options(params))
    rescue Braintree::ErrorResult
      # The card has been declined
      charge = nil
    end
    charge
  end

  def sale_options(params)
    # token = params[:payment_method_nonce]
    token = Braintree::Test::Nonce::PayPalOneTimePayment
    customer_event_profile = @order.customer_event_profile
    amount = @order.total_stripe_formated
    sale_options = {
      amount: amount,
      payment_method_nonce: token
    }
    vault_options(sale_options, customer_event_profile.customer) unless
      customer_event_profile.gateway_customer(EventDecorator::BRAINTREE)
    sale_options
  end

  def notify_payment(charge, customer_order_creator, customer_credit_creator)
    transaction = charge.transaction
    return unless transaction.status == "authorized"
    customer_credit_creator.save(@order)
    create_payment(@order, charge)
    customer_order_creator.save(@order)
    @order.complete!
    create_vault(@order, transaction)
    send_mail_for(@order, @event)
  end

  private

  def vault_options(sale_options, customer)
    sale_options[:customer] = {
      first_name: customer.first_name,
      last_name: customer.last_name,
      email: customer.email
    }
    sale_options[:options] = {
      store_in_vault: true,
      # TODO: Testing porpouses
      submit_for_settlement: true
    }
  end

  def create_vault(order, transaction)
    customer_event_profile = order.customer_event_profile
    customer_event_profile.payment_gateway_customers
      .find_or_create_by(gateway_type: EventDecorator::BRAINTREE)
      .update(token: transaction.customer_details.id)
    customer_event_profile.save
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
                    amount: transaction.amount.to_f / 100,
                    success: true,
                    payment_type: "paypal")
  end
end
