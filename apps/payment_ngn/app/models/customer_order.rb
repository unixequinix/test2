# == Schema Information
#
# Table name: customer_orders
#
#  id                        :integer          not null, primary key
#  preevent_product_id       :integer          not null
#  customer_event_profile_id :integer          not null
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
  belongs_to :preevent_product
  belongs_to :customer_event_profile

  # Validations
  validates :preevent_product_id, :customer_event_profile_id, presence: true
end
