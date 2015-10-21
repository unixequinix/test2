class ChangeSupportEmailInEvents < ActiveRecord::Migration
  def change
    change_column :events, :support_email, :string, null: false
  end
end