class RemoveDescriptionFromTickets < ActiveRecord::Migration[5.0]
  def change
    remove_column :tickets, :description, :string if column_exists?(:tickets, :description)
  end
end
