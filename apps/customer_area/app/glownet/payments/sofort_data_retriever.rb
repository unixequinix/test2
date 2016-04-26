class Payments::SofortDataRetriever < Payments::WirecardBaseDataRetriever
  def with_params(params)
    @ip = params[:consumer_ip_address]
    @user_agent = params[:consumer_user_agent]
    self
  end

  def payment_type
    "SOFORTUEBERWEISUNG"
  end

  def success_url
    success_event_order_payment_service_asynchronous_payments_url(@current_event, @order, "sofort")
  end
  
  def failure_url
    error_event_order_payment_service_asynchronous_payments_url(@current_event,
                                                                @order.id,
                                                                "sofort")
  end

  def confirm_url
    event_order_payment_service_asynchronous_payments_url(@current_event, @order, "sofort")
  end

end
