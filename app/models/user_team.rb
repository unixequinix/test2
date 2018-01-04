class UserTeam < ApplicationRecord
  belongs_to :team
  belongs_to :user

  before_destroy :users_length

  private

  def users_length
    return true unless team.users.count == 1
    errors.add(:user_id, 'At least one user is required on team')
    false
  end
end
