class EditEventInitializationSettings < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :touchpoint_update_online_orders, :boolean if column_exists?(:events, :touchpoint_update_online_orders, :boolean)
    remove_column :events, :topup_initialize_gtag, :boolean if column_exists?(:events, :topup_initialize_gtag, :boolean)
    remove_column :events, :pos_update_online_orders, :boolean if column_exists?(:events, :pos_update_online_orders, :boolean)

    add_column :events, :stations_apply_orders, :boolean, default: true unless column_exists?(:events, :stations_apply_orders, :boolean)
    add_column :events, :stations_initialize_gtags, :boolean, default: true unless column_exists?(:events, :stations_initialize_gtags, :boolean)
  end
end
