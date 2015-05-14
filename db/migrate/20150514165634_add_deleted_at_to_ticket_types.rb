class AddDeletedAtToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :deleted_at, :datetime
    add_index :ticket_types, :deleted_at
  end
end
