class OrdersPresenter < BasePresenter
  def can_render?
    @customer.active_credentials? && @customer.orders.present?
  end

  def path
    "orders"
  end

  def orders
    @customer.orders.completed
  end
end
