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

  # Associations
  belongs_to :catalog_item
  belongs_to :profile
  has_one :online_order
  has_and_belongs_to_many :credential_assignments, join_table: :c_assignments_c_orders

  # Validations
  validates :catalog_item_id, :profile_id, presence: true

  # Origins
  TICKET_ASSIGNMENT = "ticket_assignment".freeze
  TICKET_UNASSIGNMENT = "ticket_unassignment".freeze
  DEVICE = "device".freeze
  PURCHASE = "online_purchase".freeze

  REFUND_SERVICES = [TICKET_ASSIGNMENT, DEVICE, PURCHASE].freeze
end
