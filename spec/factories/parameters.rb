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
    name { %w(iban swift).sample }
    data_type { %w(string currency integer).sample }
    category { %w(gtag refund claim).sample }
    group { %w(bank_account epg).sample }
    description { Faker::Lorem.words(2).join }
  end
end
