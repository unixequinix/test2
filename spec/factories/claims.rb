# == Schema Information
#
# Table name: claims
#
#  id                        :integer          not null, primary key
#  number                    :string           not null
#  aasm_state                :string           not null
#  completed_at              :datetime
#  total                     :decimal(8, 2)    not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  gtag_id                   :integer
#  service_type              :string
#  fee                       :decimal(8, 2)    default(0.0)
#  minimum                   :decimal(8, 2)    default(0.0)
#  customer_event_profile_id :integer
#

FactoryGirl.define do
  factory :claim do
    customer_event_profile
    number { Faker::Number.number(10) }
    total 9.98
    gtag
    service_type(%w(bank_account epg).sample)
  end
end
