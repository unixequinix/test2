class CreateGtagAndTicketReferencesToEvents < ActiveRecord::Migration
  def change
    add_column :entitlements, :event_id, :integer, null: false, index: true,
      foreign_key: true
    add_column :ticket_types, :event_id, :integer, null: false, index: true,
      foreign_key: true
    add_column :tickets, :event_id, :integer, null: false, index: true,
      foreign_key: true
    add_column :gtags, :event_id, :integer, null: false, index: true,
      foreign_key: true
    add_column :online_products, :event_id, :integer, null: false, index: true,
      foreign_key: true
  end
end