class AddDetailsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :company_name, :string
  end
end
