class CreateAdmissions < ActiveRecord::Migration
  def change
    create_table :admissions do |t|
      t.belongs_to :customer
      t.belongs_to :ticket
      t.decimal :credit, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
