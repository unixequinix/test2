class RemoveEmailFromEventRegistration < ActiveRecord::Migration[5.1]
  def up
    remove_column :event_registrations, :email
  end

  def down
    add_column :event_registrations, :email, :string
  end
end
