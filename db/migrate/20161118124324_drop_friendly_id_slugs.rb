class DropFriendlyIdSlugs < ActiveRecord::Migration
  def change
    drop_table :fiendly_id_slugs if table_exists?(:fiendly_id_slugs)
  end
end
