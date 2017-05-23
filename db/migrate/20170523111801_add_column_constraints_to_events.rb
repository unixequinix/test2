class AddColumnConstraintsToEvents < ActiveRecord::Migration[5.1]
  def change
    change_column_null :events, :gtag_type, false
    change_column_null :events, :maximum_gtag_balance, false
    change_column_null :events, :fast_removal_password, false
    change_column_null :events, :private_zone_password, false
    change_column_null :events, :sync_time_gtags, false
    change_column_null :events, :sync_time_tickets, false
    change_column_null :events, :transaction_buffer, false
    change_column_null :events, :days_to_keep_backup, false
    change_column_null :events, :sync_time_customers, false
    change_column_null :events, :sync_time_server_date, false
    change_column_null :events, :sync_time_basic_download, false
    change_column_null :events, :sync_time_event_parameters, false
    change_column_null :events, :gtag_key, false
    change_column_null :events, :topup_fee, false
    change_column_null :events, :initial_topup_fee, false
    change_column_null :events, :gtag_deposit_fee, false
    change_column_null :events, :state, false
    change_column_null :events, :credit_step, false
    change_column_null :events, :gtag_format, false
    change_column_null :events, :bank_format, false
    change_column_null :events, :app_version, false
    change_column_null :events, :timezone, false
    change_column_null :events, :start_date, false
    change_column_null :events, :end_date, false
    change_column_null :events, :token, false

    remove_column :events, :logo_updated_at, :datetime
    remove_column :events, :background_updated_at, :datetime
  end
end
