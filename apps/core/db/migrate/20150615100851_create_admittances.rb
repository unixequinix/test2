class CreateAdmittances < ActiveRecord::Migration
  def change
    create_table :admittances do |t|
      t.belongs_to :admission, index: true, foreign_key: true
      t.belongs_to :ticket, index: true, foreign_key: true
      t.datetime :deleted_at, index: true
      t.string :aasm_state

      t.timestamps null: false
    end
  end
end
