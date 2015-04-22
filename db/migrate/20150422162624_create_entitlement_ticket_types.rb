class CreateEntitlementTicketTypes < ActiveRecord::Migration
  def change
    create_table :entitlement_ticket_types do |t|
      t.belongs_to :entitlement
      t.belongs_to :ticket_type

      t.timestamps null: false
    end
  end
end