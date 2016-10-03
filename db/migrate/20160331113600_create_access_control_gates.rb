class CreateAccessControlGates < ActiveRecord::Migration
  def change
    create_table :access_control_gates do |t|
      t.references :access, null: false
      t.string :direction, null: false

      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
