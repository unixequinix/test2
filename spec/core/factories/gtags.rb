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
    tag_uid { "ERTYUJHB#{rand(100)}GH#{rand(100)}" }
    tag_serial_number { rand(10_000) }
    credential_redeemed { [true, false].sample }
    company_ticket_type

    trait :with_purchaser do
      after(:build) do |gtag|
        create :purchaser, :with_gtag_delivery_address, credentiable: gtag
      end
    end
  end
end
