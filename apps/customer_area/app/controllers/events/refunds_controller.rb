class Events::RefundsController < Events::BaseController
  skip_before_action :authenticate_customer!, only: [:create, :tipalti_success]
  skip_before_filter :verify_authenticity_token, only: [:create, :tipalti_success]
  skip_before_action :check_has_gtag!, only: [:create, :tipalti_success]

  def create
    Nokogiri::XML(request.body.read).xpath("//payfrex-response/operations/operation").each do |op|
      op_hash = Hash.from_xml(op.to_s)["operation"]
      @claim = Claim.find_by(number: op_hash["merchantTransactionId"])
      next unless @claim

      RefundService.new(@claim)
        .create(amount: op_hash["amount"],
                currency: op_hash["currency"],
                message: op_hash["message"],
                operation_type: op_hash["operationType"],
                gateway_transaction_number: op_hash["payFrexTransactionId"],
                payment_solution: op_hash["paymentSolution"],
                status: op_hash["status"])
    end
    render nothing: true
  end

  def tipalti_success
    @claim = Claim.where(profile_id: params[:customerID],
                         service_type: "tipalti",
                         aasm_state: :in_progress)
             .order(id: :desc).first

    redirect_to error_event_refunds_url(current_event) && return unless @claim

    RefundService.new(@claim)
      .create(amount: @claim.gtag.refundable_amount_after_fee("tipalti"),
              currency: I18n.t("currency_symbol"), message: "Created tipalti refund",
              payment_solution: "tipalti", status: "SUCCESS")

    redirect_to success_event_refunds_url(current_event)
  end

  def success
  end

  def error
  end
end
