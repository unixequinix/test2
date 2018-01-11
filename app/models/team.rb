class Team < ApplicationRecord
  has_many :user_teams, dependent: :destroy
  has_many :users, through: :user_teams, dependent: :nullify
  has_many :leader_teams, -> { where(leader: true) }, dependent: :destroy, class_name: "UserTeam", inverse_of: :team
  has_many :leaders, through: :leader_teams, class_name: "User", source: "user"
  has_many :guest_teams, -> { where(leader: false) }, dependent: :destroy, class_name: "UserTeam", inverse_of: :team
  has_many :guests, through: :guest_teams, class_name: "User", source: "user"
  has_many :devices, dependent: :restrict_with_error
  has_many :users, through: :user_teams, dependent: :nullify
  has_many :events, -> { distinct }, through: :users

  validates :name, presence: true
  validate :validate_initial_user

  def devices_series
    devices.select(:serie).distinct.pluck(:serie).compact
  end

  private

  def validate_initial_user
    return unless user_teams.empty? || user_teams.map(&:leader).none?
    errors.add(:user_teams, 'user must exists on initialization as leader')
    false
  end
end
