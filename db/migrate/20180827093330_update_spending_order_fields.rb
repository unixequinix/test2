class UpdateSpendingOrderFields < ActiveRecord::Migration[5.1]
  def up
    CatalogItem.where(type: %w[Credit VirtualCredit Token]).each do |cred|
      cred.spending_order = cred.position
      cred.save
    end
  end

  def down
    return
  end
end
