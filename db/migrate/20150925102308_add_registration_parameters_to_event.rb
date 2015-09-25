class AddRegistrationParametersToEvent < ActiveRecord::Migration
  def change
    add_column :events, :registration_parameters, :integer, null: false, default: 0
  end
end
