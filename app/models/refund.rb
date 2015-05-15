# == Schema Information
#
# Table name: refunds
#
#  id              :integer          not null, primary key
#  customer_id     :integer          not null
#  gtag_id         :integer          not null
#  bank_account_id :integer          not null
#  aasm_state      :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Refund < ActiveRecord::Base

  # Associations
  belongs_to :customer
  belongs_to :gtag
  belongs_to :bank_account

  accepts_nested_attributes_for :bank_account

  validates :customer, :gtag, :bank_account, :aasm_state, presence: true

  # State machine
  include AASM

  aasm do
    state :created, initial: true
    state :disabled

    event :disable do
      transitions from: :created, to: :disabled
    end
  end

end
