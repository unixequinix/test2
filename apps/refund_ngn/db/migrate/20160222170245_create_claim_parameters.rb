class CreateClaimParameters < ActiveRecord::Migration
  def change
    create_table :claim_parameters do |t|
      t.string :value, default: "", null: false
      t.references :claim_id
      t.references :parameter_id

      t.timestamps null: false
    end
  end
end