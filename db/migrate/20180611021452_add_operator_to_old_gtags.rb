class AddOperatorToOldGtags < ActiveRecord::Migration[5.1]
  def change
    Gtag.where(customer: Customer.where(operator: true)).update_all(operator: true)
  end
end
