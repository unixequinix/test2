class Payments::WirecardDataRetriever < Payments::WirecardBaseDataRetriever
  def with_params(params)
    @ip = params[:consumer_ip_address]
    @user_agent = params[:consumer_user_agent]
    @card_number = params[:card_number]
    @card_verification = params[:card_verification]
    @expiration_date = params[:expiration_date]
    self
  end

  def payment_type
    "CCARD"
  end

  def parameters
    super.merge( { card_number: "card_number" } )
  end
end
