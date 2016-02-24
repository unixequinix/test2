class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.references :event
      t.string :email, null: false, default: "", index: { unique: true }
      t.string :name, default: "", null: false
      t.string :surname, default: "", null: false
      t.string :encrypted_password, default: "",    null: false
      t.string :reset_password_token, index: { unique: true }
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.boolean :agreed_on_registration, default: false
      t.string :phone
      t.string :postcode
      t.string :address
      t.string :city
      t.string :country
      t.string :gender
      t.datetime :birthdate
      t.boolean :agreed_event_condition, default: false
      t.string :remember_token, index: { unique: true }

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end