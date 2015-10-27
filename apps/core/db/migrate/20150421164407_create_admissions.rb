class CreateAdmissions < ActiveRecord::Migration
  def change
    create_table :admissions do |t|
      t.belongs_to :customer, null: false
      t.belongs_to :ticket, null: false, index: true
      t.string :aasm_state, null: false

      t.timestamps null: false
    end
  end
end
