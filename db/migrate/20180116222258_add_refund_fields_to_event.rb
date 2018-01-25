class AddRefundFieldsToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :refund_fields, :text, default: [], array: true
  end
end
