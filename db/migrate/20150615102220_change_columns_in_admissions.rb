class ChangeColumnsInAdmissions < ActiveRecord::Migration
  def change
    remove_column :admissions, :aasm_state
    remove_column :admissions, :ticket_id
    add_column :admissions, :event_id, :integer,
      null: false, default: 1, index: true, foreign_key: true
  end
end
