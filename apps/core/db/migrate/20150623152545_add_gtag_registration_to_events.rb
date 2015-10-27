class AddGtagRegistrationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :gtag_registration, :boolean, null: false, default: true
  end
end