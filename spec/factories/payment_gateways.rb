# == Schema Information
#
# Table name: payment_gateways
#
#  created_at :datetime         not null
#  data       :json
#  gateway    :string
#  refund     :boolean
#  topup      :boolean
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payment_gateways_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_9c9a24f555  (event_id => events.id)
#

FactoryGirl.define do
  factory :payment_gateway do
    event
    gateway { %w(paypal stripe redsys).sample }
    data {}
  end
end
