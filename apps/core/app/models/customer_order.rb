# == Schema Information
#
# Table name: customer_orders
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  catalog_item_id           :integer          not null
#  origin                    :string
#  amount                    :integer
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class CustomerOrder < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  belongs_to :catalog_item
  belongs_to :customer_event_profile
  has_one :online_order
  has_and_belongs_to_many :credential_assignments, join_table: :c_assignments_c_orders

  # Validations
  validates :catalog_item_id, :customer_event_profile_id, presence: true

  # Origins
  TICKET_ASSIGNMENT = "ticket_assignment"
  DEVICE = "device"
  PURCHASE = "online_purchase"

  REFUND_SERVICES = [TICKET_ASSIGNMENT, DEVICE, PURCHASE]
end
