class Customers::RefundsController < Customers::BaseController
  skip_before_action :authenticate_customer!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_action :check_has_gtag!, only: [:create]

  def create
    response = Nokogiri::XML(request.body.read)
    operations = response.xpath("//payfrex-response/operations/operation")
    operations.each do |operation|
      operation_hash = Hash.from_xml(operation.to_s)
      puts operation_hash["operation"]["amount"]
      puts operation_hash["operation"]["currency"]
      puts operation_hash["operation"]["merchantTransactionId"]
      puts operation_hash["operation"]["message"]
      puts operation_hash["operation"]["operationType"]
      puts operation_hash["operation"]["payFrexTransactionId"]
      puts operation_hash["operation"]["paymentSolution"]
      puts operation_hash["operation"]["status"]
    end


    #if params[:Ds_Order] and params[:Ds_MerchantCode] == Rails.application.secrets.merchant_code.to_s
    #  response = params[:Ds_Response]
    #  success = response =~ /00[0-9][0-9]|0900/
    #  amount = params[:Ds_Amount].to_f / 100 # last two digits are decimals
    #  if success
    #    @order = Order.find_by(number: params[:Ds_Order])
    #    @credit_log = CreditLog.create(customer_id: @order.customer.id, transaction_type: CreditLog::CREDITS_PURCHASE, amount: @order.credits_total)
    #    payment = Payment.new(transaction_type: params[:Ds_TransactionType], card_country: params[:Ds_Card_Country], paid_at: "#{params[:Ds_Date]}, #{params[:Ds_Hour]}", order: @order, response_code: response, authorization_code: params[:Ds_AuthorisationCode], currency: params[:Ds_Currency], merchant_code: params[:Ds_MerchantCode], amount: amount,  terminal: params[:Ds_Terminal], success: true)
    #    payment.save!
    #    @order.complete!
    #    send_mail_for(@order)
    #  end
    #end
    render nothing: true
  end

  def success
  end

  def error
  end

  private

  def send_mail_for(order)
    OrderMailer.completed_email(order, current_event).deliver_later
  end

end
