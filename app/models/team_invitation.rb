class TeamInvitation < ApplicationRecord
  belongs_to :team
  belongs_to :user, optional: true

  before_destroy :users_length, prepend: true
  validates :user_id, uniqueness: { scope: %i[team_id] }, allow_nil: true
  validates :email, uniqueness: { scope: %i[team_id] }, format: Devise.email_regexp, allow_blank: true

  scope :leader, -> { where(leader: true) }

  private

  def users_length
    return true unless team.users.one?
    errors.add(:user_id, 'At least one user is required on team')
    throw :abort
  end
end
