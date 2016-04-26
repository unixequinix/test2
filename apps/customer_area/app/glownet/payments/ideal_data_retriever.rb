class Payments::IdealDataRetriever < Payments::WirecardBaseDataRetriever
  def with_params(params)
    @financial_institution = params[:financial_institution]
    @ip = params[:consumer_ip_address]
    @user_agent = params[:consumer_user_agent]
    self
  end

  def payment_type
    "IDL"
  end

  def financial_institution
    @financial_institution
  end

  def success_url
    success_event_order_payment_service_asynchronous_payments_url(@current_event, @order, "ideal")
  end

  def failure_url
    error_event_order_payment_service_asynchronous_payments_url(@current_event,
                                                                @order.id,
                                                                "ideal")
  end

  def confirm_url
    event_order_payment_service_asynchronous_payments_url(@current_event, @order, "ideal")
  end

  private

  def parameters
    super.merge( { financialInstitution: "financial_institution" } )
  end
end
