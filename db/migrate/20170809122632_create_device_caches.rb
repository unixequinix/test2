class CreateDeviceCaches < ActiveRecord::Migration[5.1]
  def change
    create_table :device_caches do |t|
      t.belongs_to :event, foreign_key: true
      t.string :category, default: 'full', null: false
      t.string :app_version, default: 'unknown', null: false

      t.timestamps
    end
  end
end
