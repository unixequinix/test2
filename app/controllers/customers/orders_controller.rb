class Customers::OrdersController < Customers::BaseController
  before_action :check_has_ticket!
  before_action :require_permission!

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    payment_form_info
  end

  private

  def payment_form_info
    # @amount = (@order.amount * 100).floor
    @amount = (20 * 100).floor
    @product_description = 'Barcelona Beach Festival Payment'
    @client_name = @order.customer.name
    code = Rails.application.secrets.merchant_code
    currency = Rails.application.secrets.merchant_currency
    transactionType = Rails.application.secrets.merchant_transaction_type
    @notificationURL = customers_payments_url
    password = Rails.application.secrets.merchant_password
    message = "#{@amount}#{@order.number}#{code}#{currency}#{transactionType}#{@notificationURL}#{password}"
    @merchant_signature = Digest::SHA1.hexdigest(message).upcase
  end

  def require_permission!
    if current_customer != Order.find(params[:id]).customer
      redirect_to customer_root_path
    end
  end

end