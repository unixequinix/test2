class Payments::WirecardDataRetriever < Payments::WirecardBaseDataRetriever
  def initialize(event, order)
    super(event, order)
    @data_storage = Payments::WirecardDataStorageInitializer.new(
      customer_id: customer_id,
      order_ident: order_ident,
      return_url: return_url,
      language: language,
      shop_id: shop_id,
      secret_key: secret_key
    ).data_storage
  end

  def with_params(params)
    @ip = params[:consumer_ip_address]
    @user_agent = params[:consumer_user_agent]
    @storage_id = params[:storage_id]
    self
  end

  def payment_type
    "CCARD"
  end

  def shop_id
    "qmore"
  end

  def order_ident
    @order.number
  end

  def return_url
    "http://2bad6936.ngrok.io/frontend/fallback_return.php"
  end

  def data_storage
    @data_storage
  end

  def data_storage_id
    @storate_id || @data_storage["storageId"]
  end

  def data_storage_javascript_url
    @data_storage["javascriptUrl"]
  end

end
