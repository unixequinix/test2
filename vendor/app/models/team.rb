class Team < ApplicationRecord
  has_many :team_invitations, dependent: :destroy
  has_many :active_team_invitations, -> { where(active: true) }, class_name: 'TeamInvitation', inverse_of: :team
  has_many :leader_teams, -> { where(leader: true) }, dependent: :destroy, class_name: "TeamInvitation", inverse_of: :team
  has_many :leaders, through: :leader_teams, class_name: "User", source: "user"
  has_many :guest_teams, -> { where(leader: false) }, dependent: :destroy, class_name: "TeamInvitation", inverse_of: :team
  has_many :guests, through: :guest_teams, class_name: "User", source: "user"
  has_many :devices, dependent: :restrict_with_error
  has_many :users, through: :active_team_invitations, dependent: :nullify
  has_many :events, -> { distinct }, through: :users

  validates :name, presence: true
  validate :validate_initial_user

  def devices_series
    devices.select(:serie).distinct.pluck(:serie).compact.sort
  end

  private

  def validate_initial_user
    return unless team_invitations.empty? || team_invitations.map(&:leader).none?

    errors.add(:team_invitations, 'user must exists on initialization as leader')
    false
  end
end
