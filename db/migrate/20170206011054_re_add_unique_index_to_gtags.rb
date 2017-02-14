class ReAddUniqueIndexToGtags < ActiveRecord::Migration[5.0]
  def change
    Event.all.each do |event|
      event.gtags.group_by(&:tag_uid)
        .select{|_, gtags| gtags.size > 1 }
        .each { |_, tags| tags.pop; tags.map.with_index {|t, i| t.update!(tag_uid:  + "#{t.tag_uid}index#{i}")} }
    end
    add_index(:gtags, [:tag_uid, :event_id], unique: true, using: :btree) unless index_exists?(:gtags, [:tag_uid, :event_id], unique: true, using: :btree)
  end
end
