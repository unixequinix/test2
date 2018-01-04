class AddSerieToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :serie, :string
  end
end
