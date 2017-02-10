# == Schema Information
#
# Table name: topup_credits
#
#  amount     :float
#
# Indexes
#
#  index_topup_credits_on_credit_id   (credit_id)
#  index_topup_credits_on_station_id  (station_id)
#
# Foreign Keys
#
#  fk_rails_c5b24eb933  (station_id => stations.id)
#

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
    errors[:credit_count] << I18n.t("errors.messages.topup_credit_count") if station.topup_credits.visible.count >= 6
  end
end
