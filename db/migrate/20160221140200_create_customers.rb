class CreateCustomers < ActiveRecord::Migration
  # rubocop:disable all
  def change
    create_table :customers do |t|
      t.references :event, null: false
      t.string :email, null: false, default: "", index: { unique: true }
      t.string :first_name, default: "", null: false
      t.string :last_name, default: "", null: false
      t.string :encrypted_password, default: "",    null: false
      t.string :reset_password_token, index: { unique: true }
      t.string :phone
      t.string :postcode
      t.string :address
      t.string :city
      t.string :country
      t.string :gender
      t.string :remember_token, index: { unique: true }
      t.integer :sign_in_count, default: 0, null: false
      t.boolean :agreed_on_registration, default: false
      t.boolean :agreed_event_condition, default: false
      t.inet :last_sign_in_ip
      t.inet :current_sign_in_ip
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.datetime :birthdate

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
  # rubocop:enable all
end
