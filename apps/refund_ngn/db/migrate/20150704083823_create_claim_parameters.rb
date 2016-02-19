class CreateClaimParameters < ActiveRecord::Migration
  def change
    create_table :claim_parameters do |t|
      t.string :value, null: false, default: ""

      t.belongs_to :claim, index: true, null: false
      t.belongs_to :parameter, index: true, null: false

      t.timestamps null: false
    end
  end
end
