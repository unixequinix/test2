class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :email, default: "", null: false, index: { unique: true }
      t.string :encrypted_password, default: "", null: false
      t.string :access_token, null: false
      t.string :reset_password_token, index: { unique: true }
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      t.timestamps null: false
    end
  end
end
