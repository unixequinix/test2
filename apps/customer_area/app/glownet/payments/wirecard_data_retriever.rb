class Payments::WirecardDataRetriever < Payments::WirecardBaseDataRetriever
  include Payments::WirecardDataStorage

  def payment_type
    "CCARD"
  end

  def shop_id
    environment = get_value_of_parameter("environment")
    environment == "production" ?  "" :  "qmore"
  end

  def order_ident
    @order.number
  end

  def auto_deposit
    "no"
  end

  def duplicate_request_check
    "false"
  end

  def window_name
    "wirecard-credit-card"
  end

  def success_url
    super("wirecard")
  end

  def failure_url
    super("wirecard")
  end

  def confirm_url
    super("wirecard")
  end

  def return_url
    "http://2bad6936.ngrok.io/frontend/fallback_return.php"
  end

  def noscript_info_url
    "http://2bad6936.ngrok.io/frontend/service_url.php"
  end

  private

  def parameters
    super.merge(
      shopId: "shop_id",
      autoDeposit: "auto_deposit",
      orderIdent: "order_ident",
      duplicateRequestCheck: "duplicate_request_check",
      windowName: "window_name",
      noscriptInfoUrl: "noscript_info_url"
    )
  end
end
