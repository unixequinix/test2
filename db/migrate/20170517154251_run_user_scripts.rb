class RunUserScripts < ActiveRecord::Migration[5.0]
  def change
    User.pluck(:id, :event_id).each do |user_id, event_id|
      next unless event_id
      EventRegistration.create!(user_id: user_id, event_id: event_id, role: 2, accepted: true, email: User.find(user_id).email)
    end

    Event.pluck(:id, :owner_id).each do |event_id, user_id|
      next unless user_id
      EventRegistration.create!(user_id: user_id, event_id: event_id, role: 2, accepted: true, email: User.find(user_id).email)
    end

    User.all.each do |user|
      user.update!(username: user.email.split("@").first)
    end
  end
end
