# == Schema Information
#
# Table name: rfid_tags
#
#  id                :integer          not null, primary key
#  tag_uid           :string
#  tag_serial_number :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :rfid_tag do
    tag_uid "MyString"
tag_serial_number "MyString"
  end

end
