# == Schema Information
#
# Table name: orders
#
#  id           :integer          not null, primary key
#  customer_id  :integer          not null
#  number       :string           not null
#  aasm_state   :string           not null
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Order < ActiveRecord::Base

  # Associations
  belongs_to :customer
  has_many :order_items
  has_many   :payments

  # Validations
  validates :customer, :order_items, :number, :aasm_state, presence: true

  # State machine
  include AASM

  aasm do
    state :started, initial: true
    state :in_progress
    state :paid
    state :completed

    event :revert do
      transitions from: :in_progress, to: :started
    end

    event :start_payment do
      transitions from: :started, to: :in_progress
    end

    event :pay do
      transitions from: :in_progress, to: :paid
    end

    event :complete do
      transitions from: :paid, to: :completed
    end
  end

  def total
    total_amount = 0
    self.order_items.each do |order_item|
      total_amount = total_amount + order_item.total
    end
    total_amount
  end

end
