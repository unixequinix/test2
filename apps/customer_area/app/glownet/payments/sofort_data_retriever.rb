class Payments::SofortDataRetriever < Payments::WirecardBaseDataRetriever
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
