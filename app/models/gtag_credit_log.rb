# == Schema Information
#
# Table name: gtag_credit_logs
#
#  id         :integer          not null, primary key
#  gtag_id    :integer          not null
#  amount     :decimal(8, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GtagCreditLog < ActiveRecord::Base

  # Associations
  belongs_to :gtag

  validates :gtag, :amount, presence: true
end
