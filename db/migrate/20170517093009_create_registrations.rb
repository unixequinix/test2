class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :event_registrations do |t|
      t.integer :role
      t.boolean :accepted
      t.string :email
      t.references :event, index: true
      t.references :user, index: true
      t.index [:event_id, :user_id], unique: true
    end

    User.pluck(:id, :event_id).each do |user_id, event_id|
      next unless event_id
      EventRegistration.create!(user_id: user_id, event_id: event_id, role: 2, accepted: true, email: User.find(user_id).email)
    end

    Event.pluck(:id, :owner_id).each do |event_id, user_id|
      next unless user_id
      EventRegistration.create!(user_id: user_id, event_id: event_id, role: 2, accepted: true, email: User.find(user_id).email)
    end
  end
end
