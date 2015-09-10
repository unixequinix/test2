# == Schema Information
#
# Table name: parameters
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  data_type   :string           not null
#  category    :string           not null
#  group       :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :parameter do
    name { Faker::Lorem.words(2).join }
    data_type { ["string", "currency", "integer"].sample }
    category { ["gtag", "refund", "claim"].sample }
    group { ["bank_account", "epg"].sample }
    description { Faker::Lorem.words(2).join }
  end
end
