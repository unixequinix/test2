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
  # TODO add counter functionality
  # acts_as_list column: :counter, scope: :customer_event_profile_id

  # Associations
  belongs_to :customer_order

  # Validations
  validates :customer_order, presence: true
end
