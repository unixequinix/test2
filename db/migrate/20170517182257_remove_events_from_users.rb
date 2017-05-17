class RemoveEventsFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :event_id, :integer
    remove_column :events, :owner_id, :integer

    User.all.each { |user| user.update_column(:role, :promoter) }
    emails = %w(jake@glownet.com vicente@glownet.com arturo@glownet.com sergio@glownet.com pablo@glownet.com jesus@glownet.com developers@glownet.com)
    emails = User.pluck(:email) if Rails.env.demo?
    User.where(email: emails).update_all(role: :admin)
  end
end
