class ChangeCustomerNullInCustomerEventProfiles < ActiveRecord::Migration
  def change
    change_column :customer_event_profiles, :customer_id, :integer, null: true
  end
end
