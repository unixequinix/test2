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
end
