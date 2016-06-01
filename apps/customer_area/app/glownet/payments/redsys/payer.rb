class Payments::Redsys::Payer
  def initialize(params)
    @params = params
  end

  def start(customer_order_creator, customer_credit_creator)
    notify_payment(customer_order_creator, customer_credit_creator)
  end

  def notify_payment(customer_order_creator, customer_credit_creator)
    event = Event.friendly.find(@params[:event_id])
    merchant_code = event.get_parameter("payment", "redsys", "code")
    return unless @params[:Ds_Order] && @params[:Ds_MerchantCode] == merchant_code
    response = @params[:Ds_Response]
    success = response =~ /00[0-9][0-9]|0900/
    amount = @params[:Ds_Amount].to_f / 100 # last two digits are decimals
    return unless success
    order = Order.find_by(number: @params[:Ds_Order])
    customer_credit_creator.save(order)
    create_payment(order, amount)
    order.complete!
    customer_order_creator.save(order, "card", "redsys")
    send_mail_for(order, event)
  end

  private

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end

  def create_payment(order, amount)
    Payment.create!(transaction_type: @params[:Ds_TransactionType],
                    card_country: @params[:Ds_Card_Country],
                    paid_at: "#{@params[:Ds_Date]}, #{@params[:Ds_Hour]}",
                    order: order,
                    response_code: @params[:Ds_Response],
                    authorization_code: @params[:Ds_AuthorisationCode],
                    currency: @params[:Ds_Currency],
                    merchant_code: @params[:Ds_MerchantCode],
                    amount: amount,
                    terminal: @params[:Ds_Terminal],
                    success: true,
                    payment_type: "redsys")
  end
end
