class Payments::Sofort::DataRetriever < Payments::Wirecard::BaseDataRetriever
  def payment_type
    "SOFORTUEBERWEISUNG"
  end

  def success_url
    super("sofort")
  end

  def failure_url
    super("sofort")
  end

  def confirm_url
    super("sofort")
  end
end
