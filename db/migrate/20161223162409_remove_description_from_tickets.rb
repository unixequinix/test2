class RemoveDescriptionFromTickets < ActiveRecord::Migration
  def change
    remove_column :tickets, :description, :string if column_exists?(:tickets, :description)
  end
end
