class RemoveUnusedUserFlagsFromPacks < ActiveRecord::Migration[5.1]
  def change
    Event.all.each do |event|
      event.packs.each do |pack|
        item = event.user_flags.find_by(name: "alcohol_forbidden")
        pack.pack_catalog_items.where(catalog_item: item, amount: 0).destroy_all
      end
    end
  end
end
