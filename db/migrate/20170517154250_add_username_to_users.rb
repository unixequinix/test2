class AddUsernameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :username, :string
    User.all.each do |user|
      user.update(username: user.email.split("@").first + SecureRandom.hex)
    end
    add_index :users, :username, unique: true
  end
end
