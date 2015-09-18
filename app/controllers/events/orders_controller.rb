class Events::OrdersController < Events::BaseController
  before_action :check_has_ticket!
  before_action :require_permission!

  def show
    @order = Order.includes(order_items: :online_product).find(params[:id])
  end

  def update
    @actual_order = Order.find(params[:id])
    if @actual_order.in_progress?
      @order = current_customer_event_profile.orders.build
      @actual_order.order_items.each do |order_item|
        @order.order_items << OrderItem.new(
            online_product_id: order_item.online_product.id,
            amount: order_item.amount,
            total: order_item.total)
      end
      @order.generate_order_number!
      @order.save
    else
      @order = @actual_order
    end
    payment_form_info
    @order.start_payment!
  end

  private

  def payment_form_info
    @iupay = params[:iupay] == 'true'
    @amount = (@order.total * 100).floor
    @product_description = current_event.name
    @client_name = @order.customer_event_profile.customer.name
    code = Rails.application.secrets.merchant_code
    currency = Rails.application.secrets.merchant_currency
    transactionType = Rails.application.secrets.merchant_transaction_type
    @notificationURL = event_payments_url(current_event)
    password = Rails.application.secrets.merchant_password
    message = "#{@amount}#{@order.number}#{code}#{currency}#{transactionType}#{@notificationURL}#{password}"
    @merchant_signature = Digest::SHA1.hexdigest(message).upcase
  end

  def require_permission!
    @order = Order.find(params[:id])
    if current_customer_event_profile != @order.customer_event_profile || @order.completed?
      flash.now[:error] = I18n.t('alerts.order_complete') if @order.completed?
      redirect_to event_url(current_event)
    end
  end

end