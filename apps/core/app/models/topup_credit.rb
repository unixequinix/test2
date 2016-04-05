# == Schema Information
#
# Table name: topup_credits
#
#  id         :integer          not null, primary key
#  amount     :integer
#  credit_id  :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TopupCredit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :credit
  has_one :station_parameter, as: :station_parametable, dependent: :destroy
  accepts_nested_attributes_for :station_parameter, allow_destroy: true

  validates :amount, :credit_id, presence: true
  validate :valid_id
  validate :valid_count

  private

  def valid_id
    credits = TopupCredit.joins(:station_parameter)
              .where(station_parameters: { station_id: station_parameter.station_id })
    return if credits.count < 6
    errors[:credit_count] << I18n.t("errors.messages.topup_credit_count")
  end

  def valid_count
    credits = TopupCredit.joins(:station_parameter)
              .where(station_parameters: { station_id: station_parameter.station_id })
              .pluck(:credit_id)
    return if credits.include?(credit_id)
    errors[:credit_id] << I18n.t("errors.messages.topup_credit_id")
  end
end
