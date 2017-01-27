class AddEventToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_reference :admins, :event, foreign_key: true, index: true
  end
end
