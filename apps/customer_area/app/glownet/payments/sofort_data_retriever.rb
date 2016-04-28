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

  def parameters
    {
      customerId: "customer_id",
      amount: "amount",
      currency: "currency",
      paymentType: "payment_type",
      language: "language",
      orderDescription: "order_description",
      successUrl: "success_url",
      cancelUrl: "cancel_url",
      failureUrl: "failure_url",
      serviceUrl: "service_url",
      confirmUrl: "confirm_url",
      consumerUserAgent: "consumer_user_agent",
      consumerIpAddress: "consumer_ip_address",
    }
  end

end
