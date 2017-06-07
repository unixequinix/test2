class AddCitextColumnType < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'citext'

    change_column :transactions, :customer_tag_uid, :citext
    change_column :transactions, :operator_tag_uid, :citext
    change_column :gtags, :tag_uid, :citext
    change_column :tickets, :code, :citext
    change_column :customers, :email, :citext
    change_column :admins, :email, :citext
  end
end
