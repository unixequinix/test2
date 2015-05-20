class Customers::OrdersController < Customers::BaseController
  before_action :check_has_ticket!
  before_action :require_permission!

  def show
    @order = Order.includes(order_items: :online_product).find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    @order.generate_order_number! if @order.in_progress?
    payment_form_info
    @order.start_payment!
  end

  private

  def payment_form_info
    @amount = (@order.total * 100).floor
    @product_description = I18n.t('event.name')
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
    @order = Order.find(params[:id])
    if current_customer != @order.customer || @order.completed?
      flash.now[:error] = I18n.t('alerts.order_complete') if @order.completed?
      redirect_to customer_root_path
    end
  end

end