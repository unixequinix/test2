class Payments::Ideal::DataRetriever < Payments::Wirecard::BaseDataRetriever
  def with_params(params)
    super(params)
    @financial_institution = params[:financial_institution]
    self
  end

  def payment_type
    "IDL"
  end

  attr_reader :financial_institution

  def success_url
    super("ideal")
  end

  def failure_url
    super("ideal")
  end

  def confirm_url
    super("ideal")
  end

  private

  def parameters
    super.merge(financialInstitution: "financial_institution")
  end
end
