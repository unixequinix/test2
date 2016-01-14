# == Schema Information
#
# Table name: tickets
#
#  id                  :integer          not null, primary key
#  ticket_type_id      :integer          not null
#  number              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  deleted_at          :datetime
#  purchaser_email     :string
#  purchaser_name      :string
#  purchaser_surname   :string
#  event_id            :integer          not null
#  barcode             :string
#  credential_redeemed :boolean          default(FALSE), not null
#  preevent_product_id :integer
#

FactoryGirl.define do
  factory :ticket do
    number { Faker::Number.number(10) }
    ticket_type
    purchaser_email { Faker::Internet.email }
    purchaser_name { Faker::Name.first_name }
    purchaser_surname { Faker::Name.last_name }
    event

  end
end
