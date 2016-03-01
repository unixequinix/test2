class Payments::RedsysPayer
  def start(params, customer_order_creator)
    notify_payment(params, customer_order_creator)
  end

  def notify_payment(params, customer_order_creator)
    event = Event.friendly.find(params[:event_id])
    merchant_code = event.get_parameter("payment", "redsys", "code")
    return unless params[:Ds_Order] && params[:Ds_MerchantCode] == merchant_code

    response = params[:Ds_Response]
    success = response =~ /00[0-9][0-9]|0900/
    amount = params[:Ds_Amount].to_f / 100 # last two digits are decimals
    return unless success
    order = Order.find_by(number: params[:Ds_Order])

    create_log(order)
    create_payment(order, amount, params)
    order.complete!
    customer_order_creator.save(order)
    send_mail_for(order, event)
  end

  def action_after_payment
    # this method will be evaluated in the controller
    "render nothing: true"
  end

  private

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end

  def create_log(order)
    CustomerCreditOnlineCreator.new(customer_event_profile: order.customer_event_profile,
                                    transaction_source: CustomerCredit::CREDITS_PURCHASE,
                                    payment_method: "none",
                                    amount: order.credits_total
                                   ).save
  end

  def create_payment(order, amount, params)
    Payment.create!(transaction_type: params[:Ds_TransactionType],
                    card_country: params[:Ds_Card_Country],
                    paid_at: "#{params[:Ds_Date]}, #{params[:Ds_Hour]}",
                    order: order, response_code: params[:Ds_Response],
                    authorization_code: params[:Ds_AuthorisationCode],
                    currency: params[:Ds_Currency], merchant_code: params[:Ds_MerchantCode],
                    amount: amount, terminal: params[:Ds_Terminal], success: true)
  end
end
