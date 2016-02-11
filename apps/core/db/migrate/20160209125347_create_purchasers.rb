class CreatePurchasers < ActiveRecord::Migration
  class Ticket < ActiveRecord::Base
  end

  def change
    create_table :purchasers do |t|
      t.references :credentiable, polymorphic: true, null: false
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :gtag_delivery_address

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    migrate_tickets
  end

  def migrate_tickets
    purchasers = Ticket.all.map do |ticket|
      if ticket.purchaser_first_name.present? || ticket.purchaser_email.present?
        Purchaser.new(
          first_name: ticket.purchaser_first_name,
          last_name: ticket.purchaser_last_name,
          email: ticket.purchaser_email,
          credentiable_id: ticket.id,
          credentiable_type: "Ticket"
        )
      end
    end
    Purchaser.import(purchasers.compact)
  end
end
