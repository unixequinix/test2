# == Schema Information
#
# Table name: customer_orders
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer
#  catalog_item_id           :integer
#  counter                   :integer
#  redeemed                  :boolean          default(FALSE), not null
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

  # Validations
  validates :catalog_item_id, :customer_event_profile_id, presence: true
end
