class AccessControlGate < ApplicationRecord
  belongs_to :access
  belongs_to :station, touch: true

  validates :direction, :access_id, presence: true

  scope(:in, -> { where(direction: "1") })
  scope(:out, -> { where(direction: "-1") })

  def self.policy_class
    StationItemPolicy
  end

  def self.sort_column
    :access_id
  end
end
