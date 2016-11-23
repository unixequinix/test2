class RefactorRefunds < ActiveRecord::Migration
  def change
    add_reference :refunds, :profile, foreign_key: true
    add_column :refunds, :fee, :decimal, precision: 8, scale: 2
    add_column :refunds, :iban, :string
    add_column :refunds, :swift, :string

    sql = "UPDATE refunds RF
           SET profile_id = CL.profile_id,
               fee = CL.fee
           FROM claims CL
           WHERE CL.id = RF.claim_id"

    ActiveRecord::Base.connection.execute(sql)

    remove_column :refunds, :currency
    remove_column :refunds, :message
    remove_column :refunds, :operation_type
    remove_column :refunds, :gateway_transaction_number
    remove_column :refunds, :payment_solution
    remove_column :refunds, :claim_id
    drop_table :claims
    drop_table :claim_parameters
  end
end
