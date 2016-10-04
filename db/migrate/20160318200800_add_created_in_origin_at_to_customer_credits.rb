class AddCreatedInOriginAtToCustomerCredits < ActiveRecord::Migration
  def change
    add_column :customer_credits, :created_in_origin_at, :datetime
  end
end
