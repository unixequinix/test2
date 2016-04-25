class Payments::SofortDataRetriever < Payments::WirecardBaseDataRetriever
  def with_params(params)
    @ip = params[:consumer_ip_address]
    @user_agent = params[:consumer_user_agent]
    self
  end

  def payment_type
    "SOFORTUEBERWEISUNG"
  end
end
