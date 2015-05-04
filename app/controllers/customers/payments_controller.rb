class Customers::PaymentsController < Customers::BaseController
  skip_before_action :authenticate_customer!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_action :check_has_ticket!, only: [:create]

  def create
    if params[:Ds_Order] and params[:Ds_MerchantCode] == Rails.application.secrets.merchant_code.to_s
      response = params[:Ds_Response]
      success = response =~ /00[0-9][0-9]|0900/
      amount = params[:Ds_Amount].to_f / 100 # last two digits are decimals
      if success
        @order = Order.find_by(number: params[:Ds_Order])
        @order.complete!
        payment = Payment.new(transaction_type: params[:Ds_TransactionType], card_country: params[:Ds_Card_Country], paid_at: "#{params[:Ds_Date]}, #{params[:Ds_Hour]}", order: @order, response_code: response, authorization_code: params[:Ds_AuthorisationCode], currency: params[:Ds_Currency], merchant_code: params[:Ds_MerchantCode], amount: amount,  terminal: params[:Ds_Terminal], success: true)
        payment.save!
      end
    end
    render nothing: true
  end

  def success
    ticket_credits = 0
    if !current_customer.assigned_admission.nil?
      @admission = Admission.includes(:ticket, ticket: [:ticket_type]).find(current_customer.assigned_admission.id)
      ticket_credits = @admission.ticket.ticket_type.credit
    end
    @total_credits = ticket_credits + current_customer.credits
  end

  def error
    ticket_credits = 0
    if !current_customer.assigned_admission.nil?
      @admission = Admission.includes(:ticket, ticket: [:ticket_type]).find(current_customer.assigned_admission.id)
      ticket_credits = @admission.ticket.ticket_type.credit
    end
    @total_credits = ticket_credits + current_customer.credits
  end

end