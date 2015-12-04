class CreateEntitlementTicketTypes < ActiveRecord::Migration
  def change
    create_table :entitlement_ticket_types do |t|
      t.belongs_to :entitlement, null: false
      t.belongs_to :ticket_type, null: false

      t.timestamps null: false
    end
  end
end