class AddIndexToGtagUid < ActiveRecord::Migration[5.0]
  def change
    tags = Gtag.select(:id, :event_id, :tag_uid, :activation_counter).group(:event_id, :tag_uid, :activation_counter).having("count(*) > 1")
    SaleItem.wher(credit_transaction: Transaction.wher(gtag: tags)).destroy_all
    Transaction.wher(gtag: tags)
    tags.destroy_all
    add_index :gtags, [:event_id, :tag_uid, :activation_counter], unique: true
  end
end
