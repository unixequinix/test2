class AddCountryToEvents < ActiveRecord::Migration
  def change
    add_column :events, :host_country, :string, null: false
  end
end
