class CheckoutForm
  include ActiveModel::Model
  attr_reader :order

  def initialize(profile)
    @profile = profile
    @order = Order.new
  end

  def submit(params, catalog_items_fetched)
    persist(params, catalog_items_fetched)
  end

  private

  def persist(params, catalog_items_fetched)
    @order.profile = @profile
    @order.generate_order_number!
    catalog_items_fetched.each do |catalog_item|
      amount = params[:catalog_items][catalog_item.id.to_s].to_i
      next unless !amount.nil? && amount > 0
      @order.order_items << OrderItem.new(
        catalog_item_id: catalog_item.id,
        amount: amount,
        total: amount * catalog_item.price
      )
    end
    @order.save
  end
end
