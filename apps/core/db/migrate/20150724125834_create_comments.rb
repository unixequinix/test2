class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, null: false
      t.integer :admin_id
      t.text :body

      t.timestamps null: false
    end
  end
end