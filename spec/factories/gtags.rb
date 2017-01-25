# == Schema Information
#
# Table name: gtags
#
#  activation_counter       :integer          default(1)
#  active                   :boolean          default(TRUE)
#  banned                   :boolean          default(FALSE)
#  credits                  :decimal(8, 2)
#  final_balance            :decimal(8, 2)
#  final_refundable_balance :decimal(8, 2)
#  format                   :string           default("wristband")
#  loyalty                  :boolean          default(FALSE)
#  refundable_credits       :decimal(8, 2)
#
# Indexes
#
#  index_gtags_on_activation_counter                           (activation_counter)
#  index_gtags_on_customer_id                                  (customer_id)
#  index_gtags_on_event_id                                     (event_id)
#  index_gtags_on_event_id_and_tag_uid_and_activation_counter  (event_id,tag_uid,activation_counter) UNIQUE
#  index_gtags_on_tag_uid                                      (tag_uid)
#
# Foreign Keys
#
#  fk_rails_084fd46c5e  (event_id => events.id)
#  fk_rails_70b4405c01  (customer_id => customers.id)
#

FactoryGirl.define do
  factory :gtag do
    event
    credits 0
    refundable_credits 0
    final_balance 0
    final_refundable_balance 0
    sequence(:tag_uid) { |n| "TAGUID#{n}" }
  end
end
