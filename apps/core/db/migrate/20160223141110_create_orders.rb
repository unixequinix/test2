class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :number, null: false, index: true, unique: true
      t.string :aasm_state, null: false
      t.integer :customer_event_profile_id, index: true

      t.datetime :completed_at
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
