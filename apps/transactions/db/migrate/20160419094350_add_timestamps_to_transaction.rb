class AddTimestampsToTransaction < ActiveRecord::Migration
  def change
    change_table :money_transactions do |t|
      t.timestamps
    end
    change_table :credit_transactions do |t|
      t.timestamps
    end
    change_table :credential_transactions do |t|
      t.timestamps
    end
    change_table :order_transactions do |t|
      t.timestamps
    end
    change_table :access_transactions do |t|
      t.timestamps
    end
  end
end
