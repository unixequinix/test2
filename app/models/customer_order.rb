# == Schema Information
#
# Table name: customer_orders
#
#  id              :integer          not null, primary key
#  profile_id      :integer          not null
#  catalog_item_id :integer          not null
#  origin          :string
#  amount          :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CustomerOrder < ActiveRecord::Base
  acts_as_paranoid

  # Origins
  TICKET_ASSIGNMENT = "ticket_assignment".freeze
  PURCHASE = "online_purchase".freeze
  REFUND = "online_refund".freeze

  # Associations
  belongs_to :catalog_item
  belongs_to :profile

  # Validations
  validates :catalog_item_id, :profile_id, presence: true

  before_validation :set_counter
  after_destroy :recalculate_counter

  def set_counter
    self.counter = last_position + 1 if id.nil?
  end

  def last_position
    profile.customer_orders.order("counter DESC").first.try(:counter).to_i
  end

  def recalculate_counter
    customer_orders = profile.customer_orders.where("counter > ? ", counter)
    customer_orders.each { |order| CustomerOrder.decrement_counter(:counter, order.id) }
  end
end
