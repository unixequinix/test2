class AddIndexToGtagUid < ActiveRecord::Migration[5.0]
  def change
    tags = Gtag.select(:event_id, :tag_uid, :activation_counter).group(:event_id, :tag_uid, :activation_counter).having("count(*) > 1").map(&:tag_uid)
    tags = Gtag.where(tag_uid: tags)
    SaleItem.where(credit_transaction: Transaction.where(gtag: tags)).delete_all
    Transaction.where(gtag: tags).delete_all
    tags.destroy_all
    add_index :gtags, [:event_id, :tag_uid, :activation_counter], unique: true
  end
end
