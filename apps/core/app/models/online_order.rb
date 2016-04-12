# == Schema Information
#
# Table name: online_orders
#
#  id                :integer          not null, primary key
#  customer_order_id :integer          not null
#  counter           :integer
#  redeemed          :boolean
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class OnlineOrder < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  belongs_to :customer_order

  # Validations
  validates :customer_order, presence: true

  # Callbacks
  before_validation :set_counter
  after_destroy :calculate_counter

  def set_counter
    self.counter = last_position + 1 if id.nil?
  end

  def last_position
    profile = customer_order.customer_event_profile
    OnlineOrder.joins(:customer_order)
      .where(customer_orders: { customer_event_profile_id: profile.id })
      .order("counter DESC")
      .first.try(:counter) || 0
  end

  def calculate_counter
    OnlineOrder.joins(:customer_order)
      .where(customer_orders: { customer_event_profile: profile })
      .where("counter > ? ", counter)
      .each { |o_order| OnlineOrder.decrement_counter(:counter, o_order.id) }
  end
end
