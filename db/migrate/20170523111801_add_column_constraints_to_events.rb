class AddColumnConstraintsToEvents < ActiveRecord::Migration[5.1]
  def change
    Event.where(transaction_buffer: nil).update_all(transaction_buffer: 100)
    Event.where(days_to_keep_backup: nil).update_all(days_to_keep_backup: 5)
    Event.where(sync_time_customers: nil).update_all(sync_time_customers: 5)
    Event.where(sync_time_server_date: nil).update_all(sync_time_server_date: 5)
    Event.where(sync_time_basic_download: nil).update_all(sync_time_basic_download: 5)
    Event.where(sync_time_event_parameters: nil).update_all(sync_time_event_parameters: 5)
    Event.where(gtag_key: nil).update_all(gtag_key: "FOOBARBAZ")
    Event.where(topup_fee: nil).update_all(topup_fee: 1)
    Event.where(initial_topup_fee: nil).update_all(initial_topup_fee: 1)
    Event.where(gtag_deposit_fee: nil).update_all(gtag_deposit_fee: 1)
    Event.where(credit_step: nil).update_all(credit_step: 1)
    Event.where(gtag_format: nil).update_all(gtag_format: 1)
    Event.where(bank_format: nil).update_all(bank_format: 0)
    Event.where(app_version: nil).update_all(app_version: "all")
    Event.where(timezone: nil).update_all(timezone: "Madrid")
    Event.where(start_date: nil).update_all(start_date: Date.today - 100)
    Event.where(end_date: nil).update_all(end_date: Date.today - 100)
    Event.where(token: nil).update_all(token: "FOOBARBAZ#{rand(1456789)}")

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
