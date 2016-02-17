# == Schema Information
#
# Table name: preevent_products
#
#  id                   :integer          not null, primary key
#  event_id             :integer          not null
#  name                 :string
#  online               :boolean          default(FALSE), not null
#  initial_amount       :integer
#  step                 :integer
#  max_purchasable      :integer
#  min_purchasable      :integer
#  price                :decimal(, )
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  preevent_items_count :integer          default(0), not null
#

require "rails_helper"

RSpec.describe PreeventProduct, type: :model do
  it { is_expected.to validate_presence_of(:event_id) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:initial_amount) }
  it { is_expected.to validate_presence_of(:step) }
  it { is_expected.to validate_presence_of(:max_purchasable) }
  it { is_expected.to validate_presence_of(:min_purchasable) }
  it { is_expected.to validate_numericality_of(:price) }

  it "returns the price rounded" do
    first_product = create(:preevent_product, :full, price: 10)
    second_product = create(:preevent_product, :full, price: 10.0)
    third_product = create(:preevent_product, :full, price: 10.5)
    expect(first_product.rounded_price).to eq(10)
    expect(second_product.rounded_price).to eq(10)
    expect(third_product.rounded_price).to eq(10.5)
  end

  it "returns an array with all the elements for the client view sorted this way: [C V CT P]" do
    @event = create(:event)
    create(:preevent_product, :standard_credit_product, event: @event)
    create(:preevent_product, :credential_product, event: @event)
    create(:preevent_product, :voucher_product, event: @event)
    create(:preevent_product, :voucher_product, event: @event)
    create(:preevent_product, :credential_product, :voucher_product, event: @event)
    create(:preevent_product, :full, event: @event)
    create(:preevent_product, :full, event: @event)

    sortered_array = PreeventProduct.online_preevent_products_sortered(@event)
    expect(sortered_array.count).to eq(7)
    expect(sortered_array[0].preevent_items_count).to eq(1)
    expect(sortered_array[0].product_category).to eq("Credit")
    expect(sortered_array[1].preevent_items_count).to eq(1)
    expect(sortered_array[1].product_category).to eq("Voucher")
    expect(sortered_array[2].preevent_items_count).to eq(1)
    expect(sortered_array[2].product_category).to eq("Voucher")
    expect(sortered_array[3].preevent_items_count).to eq(1)
    expect(sortered_array[3].product_category).to eq("CredentialType")
    expect(sortered_array[5].preevent_items_count).to eq(3)
    expect(sortered_array[5].product_category).to eq("Pack")
  end

  it "returns an array with the order of the categories that will be used in customer area" do
    expect(PreeventProduct.keys_sortered).to eq(%w(Credit Voucher CredentialType Pack))
  end

  it "returns a category depending on its preevent items" do
    @event = create(:event)
    category = create(:preevent_product, :credit_product, event: @event).product_category
    expect(category).to eq("Credit")
    category = create(:preevent_product, :credential_product, event: @event).product_category
    expect(category).to eq("CredentialType")
    category = create(:preevent_product, :voucher_product, event: @event).product_category
    expect(category).to eq("Voucher")
    category = create(:preevent_product, :full, event: @event).product_category
    expect(category).to eq("Pack")
  end

  it "returns true if it can't be modified because of its content" do
    @event = create(:event)
    product_right = create(:preevent_product, :standard_credit_product, event: @event)
    product_wrong = create(:preevent_product, :credit_product, event: @event)

    expect(product_right.immutable?).to be(true)
    expect(product_wrong.immutable?).to be(false)
  end
end
