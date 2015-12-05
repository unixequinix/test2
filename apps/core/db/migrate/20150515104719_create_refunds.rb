class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.belongs_to :customer, null: false
      t.belongs_to :gtag, null: false
      t.belongs_to :bank_account, null: false
      t.string :aasm_state, null: false

      t.timestamps null: false
    end
  end
end
