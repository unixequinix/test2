class AddIndexToGtagUid < ActiveRecord::Migration[5.0]
  def change
    tags = Gtag.select(:event_id, :tag_uid, :activation_counter).group(:event_id, :tag_uid, :activation_counter).having("count(*) > 1").map(&:tag_uid)
    Gtag.where(tag_uid: tags).group_by { |tag| [tag.tag_uid, tag.activation_counter] }.each do |_, tags|
      next if tags.size == 1
      first = tags.first
      rest = tags.drop(1)
      Transaction.where(gtag_id: rest.map(&:id)).update_all(gtag_id: first.id, updated_at: Time.zone.now)
      rest.map(&:delete)
    end

    add_index :gtags, [:event_id, :tag_uid, :activation_counter], unique: true
  end
end
