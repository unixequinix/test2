class AddIndexToGtagUid < ActiveRecord::Migration[5.0]
  def change
    tags = Gtag.select(:id, :event_id, :tag_uid, :activation_counter).group(:event_id, :tag_uid, :activation_counter).having("count(*) > 1").pluck(:id)
    SaleItem.where(credit_transaction: Transaction.where(gtag_id: tags)).destroy_all
    Transaction.where(gtag_id: tags)
    Gtag.where(id: tags).destroy_all
    add_index :gtags, [:event_id, :tag_uid, :activation_counter], unique: true
  end
end
