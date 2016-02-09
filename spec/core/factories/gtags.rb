# == Schema Information
#
# Table name: gtags
#
#  id                     :integer          not null, primary key
#  tag_uid                :string           not null
#  tag_serial_number      :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  event_id               :integer          not null
#  credential_redeemed    :boolean          default(FALSE), not null
#  company_ticket_type_id :integer
#

FactoryGirl.define do
  factory :gtag do
    event
    tag_uid { Faker::Lorem.characters(10) }
    tag_serial_number { Faker::Lorem.characters(10) }
    credential_redeemed { [true, false].sample }
    company_ticket_type

    trait :banned do
      after(:create) do |gtag|
        create(:banned_gtag, gtag: gtag)
      end
    end
  end
end
