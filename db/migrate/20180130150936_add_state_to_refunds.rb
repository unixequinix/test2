class AddStateToRefunds < ActiveRecord::Migration[5.1]
  def change
    add_column :refunds, :old_status, :integer, default: 1
  end
end
