class CreateAlerts < ActiveRecord::Migration[5.1]
  def change
    create_table :alerts do |t|
      t.belongs_to :event, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false
      t.references :subject, polymorphic: true
      t.integer :priority, default: 0
      t.boolean :resolved, default: false
      t.string :body

      t.timestamps
    end
  end
end
