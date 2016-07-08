class Payments::Redsys::DataRetriever < Payments::BaseDataRetriever
  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order

  def initialize(event, order)
    @current_event = event
    @order = order
    @payment_parameters = Parameter.joins(:event_parameters)
                                   .where(category: "payment",
                                          group: "redsys",
                                          event_parameters: { event: event })
                                   .select("parameters.name, event_parameters.*")
  end

  def form
    get_value_of_parameter("form")
  end

  def signature_version
    "HMAC_SHA256_V1"
  end

  def basic_parameters
    {
      "Ds_Merchant_Amount" => amount,
      "Ds_Merchant_Order" => @order.number,
      "Ds_Merchant_MerchantCode" => code,
      "Ds_Merchant_Currency" => currency,
      "Ds_Merchant_TransactionType" => transaction_type,
      "Ds_Merchant_Terminal" => terminal,
      "Ds_Merchant_MerchantURL" => notification_url,
      "Ds_Merchant_UrlOK" => success_url,
      "Ds_Merchant_UrlKO" => error_url
    }
  end

  def parameters
     Base64.strict_encode64(basic_parameters.to_json)
  end

  def signature
    unique_key_per_order = encrypt_3DES(@order.number, Base64.decode64(password))
    sign_hmac256(parameters, unique_key_per_order)
  end

  private

  def sign_hmac256(data, key)
    Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, data))
  end

  def encrypt_3DES(data, key)
    cipher = OpenSSL::Cipher::Cipher.new("DES-EDE3-CBC")
    cipher.encrypt
    cipher.key = key
    if (data.bytesize % 8) > 0
      data += "\0" * (8 - data.bytesize % 8)
    end
    cipher.update(data)
  end

  def amount
    (@order.total * 100).floor
  end

  def name
    get_value_of_parameter("name")
  end

  def code
    get_value_of_parameter("code")
  end

  def terminal
    get_value_of_parameter("terminal")
  end

  def currency
    get_value_of_parameter("currency")
  end

  def transaction_type
    get_value_of_parameter("transaction_type")
  end

  def password
    get_value_of_parameter("password")
  end

  def pay_methods
    "0"
  end

  def product_description
    @current_event.name
  end

  def client_name
    @order.profile.customer.first_name
  end

  def notification_url
    event_order_payment_service_asynchronous_payments_url(@current_event, @order, "redsys")
  end

  def success_url
    success_event_order_payment_service_asynchronous_payments_url(@current_event, @order, 'redsys')
  end

  def error_url
    error_event_order_payment_service_asynchronous_payments_url(@current_event, @order, 'redsys')
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.value
  end
end
