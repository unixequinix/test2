class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.belongs_to :ticket_type
      t.string :number

      t.timestamps null: false
    end
  end
end
