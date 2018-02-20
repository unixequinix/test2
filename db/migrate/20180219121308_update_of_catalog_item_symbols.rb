class UpdateOfCatalogItemSymbols < ActiveRecord::Migration[5.1]
  def change
    CatalogItem.where(symbol: "☉").update_all(symbol: "C")
  end
end
