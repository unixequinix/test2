class RemoveCustomerIdFromGtagRegistration < ActiveRecord::Migration
  def change
    remove_column :gtag_registrations, :customer_id
  end
end
