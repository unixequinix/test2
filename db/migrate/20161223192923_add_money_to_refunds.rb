class AddMoneyToRefunds < ActiveRecord::Migration
  def change
    add_column(:refunds, :money, :decimal, precision: 8, scale: 2, default: 1.0, null: false) unless column_exists?(:refunds, :money)
  end
end
