class CreateFriendlyIdSlugs < ActiveRecord::Migration
  def change
    create_table :friendly_id_slugs do |t|
      t.references :sluggable, polymorphic: true, null: false
      t.string :slug, null: false, index: true, unique: true
      t.string :scope

      t.timestamps null: false
    end
  end
end
