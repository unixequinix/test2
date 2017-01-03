# == Schema Information
#
# Table name: payment_gateways
#
#  data                :jsonb            not null
#  gateway             :string
#  refund              :boolean
#  refund_field_a_name :string           default("iban")
#  refund_field_b_name :string           default("swift")
#  topup               :boolean
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
