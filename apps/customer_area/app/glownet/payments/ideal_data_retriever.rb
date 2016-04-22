class Payments::IdealDataRetriever < Payments::WirecardDataRetriever
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

  private

  def parameters
    super.merge( { financialInstitution: "financial_institution" } )
  end
end
