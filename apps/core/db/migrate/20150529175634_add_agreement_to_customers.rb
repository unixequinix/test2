class AddAgreementToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :agreed_on_registration, :boolean, default: false
  end
end
