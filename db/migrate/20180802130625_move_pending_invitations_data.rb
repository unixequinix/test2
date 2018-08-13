class MovePendingInvitationsData < ActiveRecord::Migration[5.1]
  def up
    EventRegistration.where('user_id is null').each do |er|
      er.event.event_invitations&.create(email: er.email || "#{SecureRandom.hex}@glownet.com", role: er.role)
      er.destroy
    end
  end

  def down
    EventRegistration.all.includes(:user).each do |er|
      er&.update(email: er.user.email)
    end

    EventInvitation.where(accepted: false).each do |ei|
      ei.event.event_registrations&.create(email: ei.email, role: ei.role)
      ei.destroy
    end
  end
end
