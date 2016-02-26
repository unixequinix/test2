class CreateClaimParameters < ActiveRecord::Migration
  def change
    create_table :claim_parameters do |t|
      t.string :value, default: "", null: false
      t.references :claim, null: false
      t.references :parameter, null: false

      t.timestamps null: false
    end
  end
end
