# == Schema Information
#
# Table name: claims
#
#  id           :integer          not null, primary key
#  customer_id  :integer          not null
#  number       :string           not null
#  aasm_state   :string           not null
#  completed_at :datetime
#  total        :decimal(8, 2)    not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Claim < ActiveRecord::Base
  # Associations
  belongs_to :customer
  has_many :refunds

  # Validations
  validates :customer, :number, :total, :aasm_state, presence: true

  # State machine
  include AASM

  aasm do
    state :started, initial: true
    state :in_progress
    state :completed, enter: :complete_order

    event :start_claim do
      transitions from: [:started, :in_progress], to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end
  end

  def generate_claim_number!
    time_hex = Time.now.strftime('%H%M%L').to_i.to_s(16)
    day = Date.today.strftime('%y%m%d')
    self.number = "#{day}#{time_hex}"
  end

  private

  def complete_claim
    self.update(completed_at: Time.now())
  end
end
