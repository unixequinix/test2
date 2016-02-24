class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.references  :customer_event_profile
      t.references :gtag
      t.string :number, null: false, index: true, unique: true
      t.string :aasm_state, null: false
      t.decimal :total, precision: 8, scale: 2, null: false
      t.string :service_type
      t.decimal :fee, precision: 8, scale: 2, default: 0.0
      t.decimal :minimum, precision: 8, scale: 2, default: 0.0

      t.datetime :completed_at
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end