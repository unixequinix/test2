class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :access_token

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
