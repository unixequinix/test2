class CreateTopupCredit < ActiveRecord::Migration
  def change
    create_table :topup_credits do |t|
      t.integer :amount
      t.references :credit, index: true, foreign_key: true

      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
