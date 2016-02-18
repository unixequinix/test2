class AddColumnsToTransactions < ActiveRecord::Migration
  def change
    add_column :monetary_transactions, :event_id, :integer
    add_column :monetary_transactions, :transaction_type, :string
    add_column :monetary_transactions, :device_created_at, :datetime
    add_column :monetary_transactions, :customer_tag_uid, :string
    add_column :monetary_transactions, :operator_tag_uid, :string
    add_column :monetary_transactions, :station_id, :integer
    add_column :monetary_transactions, :device_id, :integer
    add_column :monetary_transactions, :device_uid, :integer
    add_column :monetary_transactions, :customer_event_profile_id, :integer
    add_column :monetary_transactions, :status_code, :string
    add_column :monetary_transactions, :status_message, :string
    add_column :monetary_transactions, :created_at, :datetime
    add_column :monetary_transactions, :updated_at, :datetime
    remove_column :monetary_transactions, :transaction_parameter_id, :integer

    add_column :credential_transactions, :event_id, :integer
    add_column :credential_transactions, :transaction_type, :string
    add_column :credential_transactions, :device_created_at, :datetime
    add_column :credential_transactions, :customer_tag_uid, :string
    add_column :credential_transactions, :operator_tag_uid, :string
    add_column :credential_transactions, :station_id, :integer
    add_column :credential_transactions, :device_id, :integer
    add_column :credential_transactions, :device_uid, :integer
    add_column :credential_transactions, :customer_event_profile_id, :integer
    add_column :credential_transactions, :status_code, :string
    add_column :credential_transactions, :status_message, :string
    add_column :credential_transactions, :created_at, :datetime
    add_column :credential_transactions, :updated_at, :datetime
    remove_column :credential_transactions, :transaction_parameter_id, :integer

    add_column :access_transactions, :event_id, :integer
    add_column :access_transactions, :transaction_type, :string
    add_column :access_transactions, :device_created_at, :datetime
    add_column :access_transactions, :customer_tag_uid, :string
    add_column :access_transactions, :operator_tag_uid, :string
    add_column :access_transactions, :station_id, :integer
    add_column :access_transactions, :device_id, :integer
    add_column :access_transactions, :device_uid, :integer
    add_column :access_transactions, :customer_event_profile_id, :integer
    add_column :access_transactions, :status_code, :string
    add_column :access_transactions, :status_message, :string
    add_column :access_transactions, :created_at, :datetime
    add_column :access_transactions, :updated_at, :datetime
    remove_column :access_transactions, :transaction_parameter_id, :integer

    drop_table :transaction_parameters
  end
end
