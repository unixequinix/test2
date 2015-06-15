# == Schema Information
#
# Table name: credits
#
#  id         :integer          not null, primary key
#  standard   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

FactoryGirl.define do
  factory :credit do
    standard true

    after :build do |credit|
      credit.online_product = build(:online_product, purchasable: credit)
    end
  end
end
