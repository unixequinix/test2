class CreateBannedGtags < ActiveRecord::Migration
  def change
    create_table :banned_gtags do |t|
      t.references  :gtag, null: false
      t.timestamps null: false
    end
  end
end
