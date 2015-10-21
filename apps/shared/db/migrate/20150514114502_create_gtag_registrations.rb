class CreateGtagRegistrations < ActiveRecord::Migration
  def change
    create_table :gtag_registrations do |t|
      t.belongs_to :customer, null: false
      t.belongs_to :gtag, null: false, index: true
      t.string :aasm_state

      t.timestamps null: false
    end
  end
end
