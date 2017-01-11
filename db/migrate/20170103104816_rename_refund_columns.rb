class RenameRefundColumns < ActiveRecord::Migration
  def change
    rename_column :refunds, :iban, :field_a
    rename_column :refunds, :swift, :field_b

    add_column :payment_gateways, :refund_field_a_name, :string, default: "iban" unless column_exists?(:payment_gateways, :refund_field_a_name)
    add_column :payment_gateways, :refund_field_b_name, :string, default: "swift" unless column_exists?(:payment_gateways, :refund_field_bname)
  end
end
