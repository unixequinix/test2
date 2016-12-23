class RemoveDescriptionFromTickets < ActiveRecord::Migration
  def change
    remove_column :tickets, :description, :string
  end
end
