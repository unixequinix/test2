class CreateTicketTypes < ActiveRecord::Migration
  def change
    create_table :ticket_types do |t|
      t.string :name, null: false
      t.string :company, null: false
      t.decimal :credit, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
