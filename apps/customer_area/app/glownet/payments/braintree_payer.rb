class Payments::BraintreePayer
  include Rails.application.routes.url_helpers
  attr_reader :action_after_payment

  def initialize
    @action_after_payment = ""
  end

  def start(params, customer_order_creator)
    @event = Event.friendly.find(params[:event_id])
    @order = Order.find(params[:order_id])
    @order.start_payment!
    @customer_order_creator = customer_order_creator
    charge_object = charge(params)
    if charge_object.success?
      notify_payment(charge_object)
      @action_after_payment = success_event_order_synchronous_payments_path(@event, @order)
    else
      @action_after_payment = error_event_order_synchronous_payments_path(@event, @order)
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
    token = params[:payment_method_nonce]
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

  def notify_payment(charge)
    transaction = charge.transaction
    return unless transaction.status == "authorized"
    create_log(@order)
    create_payment(@order, charge)
    @customer_order_creator.save(@order)
    @order.complete!
    create_vault(@order, transaction)
    send_mail_for(@order, @event)
  end

  private

  def vault_options(sale_options, customer)
    sale_options[:customer] = {
      first_name: customer.name,
      last_name: customer.surname,
      email: customer.email
    }
    sale_options[:options] = {
      store_in_vault: true
    }
  end

  def create_vault(order, transaction)
    customer_event_profile = order.customer_event_profile
    customer_event_profile.gateway_customer(EventDecorator::BRAINTREE)
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

  def create_log(order)
    CustomerCreditOnlineCreator.new(customer_event_profile: order.customer_event_profile,
                                    transaction_origin: CustomerCredit::CREDITS_PURCHASE,
                                    amount: order.credits_total,
                                    payment_method: "none",
                                    money_payed: order.total
                                   ).save
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
                    payment_type: "braintree")
  end
end
