# == Schema Information
#
# Table name: customer_orders
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  catalog_item_id           :integer          not null
#  counter                   :integer
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class CustomerOrder < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list column: :counter, scope: :customer_event_profile_id

  # Associations
  belongs_to :catalog_item
  belongs_to :customer_event_profile
  has_one :online_order

  # Validations
  validates :catalog_item_id, :customer_event_profile_id, presence: true
end
