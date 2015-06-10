# == Schema Information
#
# Table name: events
#
#  id                      :integer          not null, primary key
#  name                    :string
#  aasm_state              :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string
#  location                :string
#  start_date              :datetime
#  end_date                :datetime
#  description             :text
#  support_email           :string
#  style                   :text
#  logo_file_name          :string
#  logo_content_type       :string
#  logo_file_size          :integer
#  logo_updated_at         :datetime
#  background_file_name    :string
#  background_content_type :string
#  background_file_size    :integer
#  background_updated_at   :datetime
#

FactoryGirl.define do
  factory :event do
    name "MyString"
aasm_state "MyString"
  end

end
