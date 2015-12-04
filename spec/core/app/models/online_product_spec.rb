# == Schema Information
#
# Table name: online_products
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  description      :string           not null
#  price            :decimal(8, 2)    not null
#  purchasable_id   :integer          not null
#  purchasable_type :string           not null
#  min_purchasable  :integer
#  max_purchasable  :integer
#  initial_amount   :integer
#  step             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  event_id         :integer          not null
#

require "rails_helper"

RSpec.describe OnlineProduct, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:price) }
  it { is_expected.to validate_presence_of(:min_purchasable) }
  it { is_expected.to validate_presence_of(:max_purchasable) }
  it { is_expected.to validate_presence_of(:initial_amount) }
  it { is_expected.to validate_presence_of(:step) }


  it "returns the price formated. It returns the price truncated if the decimal is .0, if it is not, it returns the number without any change" do
    online_product = build(:online_product, price: 1.0)
    expect(online_product.rounded_price).to eq(1)

    online_product = build(:online_product, price: 1.5)
    expect(online_product.rounded_price).to eq(1.5)
  end

end
