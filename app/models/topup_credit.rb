class TopupCredit < ActiveRecord::Base
  belongs_to :credit
  belongs_to :station, touch: true

  validates :amount, uniqueness: { scope: :station_id }
  validates :amount, :credit_id, presence: true
  validate :valid_topup_credit, on: :create

  scope :visible, -> { where(hidden: [false, nil]) }

  def self.policy_class
    StationItemPolicy
  end

  def self.sort_column
    :amount
  end

  private

  def valid_topup_credit
    return unless station
    errors[:credit_count] << I18n.t("errors.messages.topup_credit_count") if station.topup_credits.visible.count > 6
  end
end
