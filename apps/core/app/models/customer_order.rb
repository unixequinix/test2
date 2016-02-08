# == Schema Information
#
# Table name: customer_orders
#
#  id                        :integer          not null, primary key
#  event_id                  :integer          not null
#  preevent_product_id       :integer          not null
#  customer_event_profile_id :integer          not null
#  counter                   :integer
#  aasm_state                :string           default("unredeemed"), not null
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
  validates :state, presence: true


  include AASM
  aasm do
    state :unredeemed, initial: true
    state :redeemed

    event :redeem do
      transitions from: :unredeemed, to: :redeemed
    end

    event :unredeem do
      transitions from: :redeemed, to: :unredeemed
    end
  end
end
