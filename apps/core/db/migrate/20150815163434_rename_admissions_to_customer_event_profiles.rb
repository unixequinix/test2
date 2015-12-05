class RenameAdmissionsToCustomerEventProfiles < ActiveRecord::Migration
  def change
    rename_table :admissions, :customer_event_profiles
    rename_column :admittances, :admission_id, :customer_event_profile_id
    rename_column :gtag_registrations, :admission_id, :customer_event_profile_id
  end
end