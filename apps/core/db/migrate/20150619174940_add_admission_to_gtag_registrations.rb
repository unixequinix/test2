class AddAdmissionToGtagRegistrations < ActiveRecord::Migration
  def change
    add_column :gtag_registrations, :admission_id, :integer,
               null: false, default: 1, index: true, foreign_key: true
  end
end
