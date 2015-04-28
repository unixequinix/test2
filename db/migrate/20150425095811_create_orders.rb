class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :customer, null: false
      t.string :number, null: false
      t.string :aasm_state, null: false
      t.datetime :completed_at

      t.timestamps null: false
    end
  end
end
