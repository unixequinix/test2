class CustomerOrderObserver < ActiveRecord::Observer
  def after_save(_order)
  end
end
