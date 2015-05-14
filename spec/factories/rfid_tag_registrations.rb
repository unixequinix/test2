# == Schema Information
#
# Table name: rfid_tag_registrations
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  rfid_tag_id :integer          not null
#  aasm_state  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :rfid_tag_registration do
    aasm_state "MyString"
  end

end
