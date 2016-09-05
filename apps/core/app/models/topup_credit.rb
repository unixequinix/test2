# == Schema Information
#
# Table name: topup_credits
#
#  id         :integer          not null, primary key
#  amount     :float
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
  validate :valid_topup_credit, on: :create

  after_update { station_parameter.station.touch }

  private

  def valid_topup_credit
    return unless station_parameter
    credits = Station.find_by(id: station_parameter.station_id).topup_credits

    errors[:credit_count] << I18n.t("errors.messages.topup_credit_count") if credits.count >= 6
    errors[:credit_id] << I18n.t("errors.messages.topup_credit_id") unless
      credits.pluck(:credit_id).include?(credit_id) || credits.empty?
  end
end
