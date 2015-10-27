# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  number                    :string           not null
#  aasm_state                :string           not null
#  completed_at              :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_event_profile_id :integer
#

class Order < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # Associations
  belongs_to :customer_event_profile
  has_many :order_items
  has_many :payments

  # Validations
  validates :customer_event_profile, :order_items, :number, :aasm_state, presence: true

  # State machine
  include AASM

  aasm do
    state :started, initial: true
    state :in_progress
    state :completed, enter: :complete_order

    event :start_payment do
      transitions from: [:started, :in_progress], to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end
  end

  def total
    self.order_items.sum(:total)
  end

  def credits_total
    self.order_items.joins(:online_product)
    .where(online_products: {purchasable_type: 'Credit',
      event_id: self.customer_event_profile.event.id}).sum(:amount)
  end

  def generate_order_number!
    time_hex = Time.now.strftime('%H%M%L').to_i.to_s(16)
    day = Date.today.strftime('%y%m%d')
    self.number = "#{day}#{time_hex}"
    self.save
  end

  private

  def complete_order
    self.update(completed_at: Time.now())
  end
end
