class AddFieldsToStats < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'

    add_column :stats, :operator_tag_uid, :citext
    add_column :stats, :customer_tag_uid, :citext
    add_column :stats, :device_uid, :citext
  end
end
