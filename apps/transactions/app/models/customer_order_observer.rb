class CustomerOrderObserver < ActiveRecord::Observer
  def after_save(order)
    atts = { order_id: order.id }
    Jobs::Base.write(atts)
  end
end
