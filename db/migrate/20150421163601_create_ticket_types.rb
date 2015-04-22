class CreateTicketTypes < ActiveRecord::Migration
  def change
    create_table :ticket_types do |t|
      t.string :name
      t.string :company
      t.decimal :credit, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
