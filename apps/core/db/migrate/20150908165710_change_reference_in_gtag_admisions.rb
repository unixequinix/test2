class ChangeReferenceInGtagAdmisions < ActiveRecord::Migration
  def change
    change_column_default :gtag_registrations, :customer_event_profile_id, nil
  end
end
