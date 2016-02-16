class CreateBannedGtags < ActiveRecord::Migration
  def change
    create_table :banned_gtags do |t|
      t.references :gtag, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
