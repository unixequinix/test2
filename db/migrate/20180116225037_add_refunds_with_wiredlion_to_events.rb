class AddRefundsWithWiredlionToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :auto_refunds, :boolean, default: false
  end
end
