class CreateAdmissions < ActiveRecord::Migration
  def change
    create_table :admissions do |t|
      t.belongs_to :customer, null: false
      t.belongs_to :ticket, null: false
      t.decimal :credit, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
