class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.belongs_to :customer, null: false
      t.string :number, null: false, index: { unique: true }
      t.string :aasm_state, null: false
      t.datetime :completed_at
      t.decimal :total, precision: 8, scale: 2, null: false

      t.timestamps null: false
    end
  end
end
