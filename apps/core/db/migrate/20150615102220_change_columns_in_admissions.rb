class ChangeColumnsInAdmissions < ActiveRecord::Migration
  def change
    remove_column :admissions, :aasm_state
    remove_column :admissions, :ticket_id
    add_column :admissions, :event_id, :integer,
               null: false, index: true, foreign_key: true
    add_column :admissions, :deleted_at, :datetime
    add_index :admissions, :deleted_at
  end
end
