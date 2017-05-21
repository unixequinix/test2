class RemoveMoneyFromRefunds < ActiveRecord::Migration[5.0]
  def change
    remove_column :refunds, :money, :decimal, precision: 8, scale: 2
  end
end
