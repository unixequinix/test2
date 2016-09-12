class AddHiddenToAccessControlGates < ActiveRecord::Migration
  def change
    add_column :access_control_gates, :hidden, :boolean, default: false
  end
end
