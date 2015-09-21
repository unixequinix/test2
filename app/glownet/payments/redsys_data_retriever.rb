class Payments::RedsysDataRetriever
  include Rails.application.routes.url_helpers
  def initialize(event, order)
    @current_event = event
    @order = order
  end

  def iupay
    @iupay
  end

  def amount
    (@order.total * 100).floor
  end

  def form
    Rails.application.secrets.merchant_form
  end

  def name
    Rails.application.secrets.merchant_name
  end

  def code
    Rails.application.secrets.merchant_code
  end

  def terminal
    Rails.application.secrets.merchant_terminal
  end

  def currency
    Rails.application.secrets.merchant_currency
  end

  def transaction_type
    Rails.application.secrets.merchant_transaction_type
  end

  def pay_methods
    '0'
  end

  def product_description
    @current_event.name
  end

  def client_name
    @order.customer_event_profile.customer.name
  end

  def code
    Rails.application.secrets.merchant_code
  end

  def currency
    Rails.application.secrets.merchant_currency
  end

  def transaction_type
    Rails.application.secrets.merchant_transaction_type
  end

  def notification_url
    event_payments_url(@current_event)
  end

  def password
    password = Rails.application.secrets.merchant_password
  end

  def message
    "#{amount}#{@order.number}#{code}#{currency}#{transaction_type}#{notification_url}#{password}"
  end

  def signature
    Digest::SHA1.hexdigest(message).upcase
  end
end