class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.boolean :standard, null: false, default: false

      t.timestamps null: false
    end
  end
end
