class Customers::RefundsController < Customers::BaseController
  skip_before_action :authenticate_customer!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_action :check_has_gtag!, only: [:create]

  def create
    response = Nokogiri::XML(request.body.read)
    operations = response.xpath("//payfrex-response/operations/operation")
    operations.each do |operation|
      operation_hash = Hash.from_xml(operation.to_s)
      if @claim = Claim.find_by(number: operation_hash["operation"]["merchantTransactionId"])
        refund = RefundService.new(@claim, current_event).create(
          params = {
            amount: operation_hash["operation"]["amount"],
            currency: operation_hash["operation"]["currency"],
            message: operation_hash["operation"]["message"],
            operation_type: operation_hash["operation"]["operationType"],
            gateway_transaction_number: operation_hash["operation"]["payFrexTransactionId"],
            payment_solution: operation_hash["operation"]["paymentSolution"],
            status: operation_hash["operation"]["status"]
        })
      end
    end
    render nothing: true
  end

  def success
  end

  def error
  end

end
