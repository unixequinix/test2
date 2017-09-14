class MoveDataAcrossProducts < ActiveRecord::Migration[5.1]
  def change
    Station.all.includes(:products).each do |station|
      station.products.each do |sp|
        old_product = OldProduct.find(sp.old_product_id)
        transactions = Transaction.credit.where(station: station)
        items = SaleItem.where(credit_transaction: transactions, old_product_id: old_product.id)

        sp.update_columns name: old_product.name, vat: old_product.vat, is_alcohol: old_product.is_alcohol, description: old_product.description
        items.update_all(product_id: sp.id)
        transactions.update_all(updated_at: Time.now)
      end
    end
  end
end
