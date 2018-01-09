class UserTeam < ApplicationRecord
  belongs_to :team
  belongs_to :user, optional: true

  before_destroy :users_length
  validates :user_id, uniqueness: { scope: %i[team_id] }, allow_nil: true
  validates :email, uniqueness: { scope: %i[team_id] }, format: Devise.email_regexp

  private

  def users_length
    return true unless team.users.count == 1
    errors.add(:user_id, 'At least one user is required on team')
    false
  end
end
