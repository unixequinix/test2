class CreatePacks < ActiveRecord::Migration
  def change
    create_table :packs do |t|
      t.timestamps null: false
    end
  end
end
