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

  it "should return the price rounded" do
    first_product = create(:preevent_product, :full, price: 10)
    second_product = create(:preevent_product, :full, price: 10.0)
    third_product = create(:preevent_product, :full, price: 10.5)
    expect(first_product.rounded_price).to eq(10)
    expect(second_product.rounded_price).to eq(10)
    expect(third_product.rounded_price).to eq(10.5)
  end

  it "should return an array with all the elements for the client view sorted this way: [C V CT P]" do
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
    expect(sortered_array[0].get_product_category).to eq("Credit")
    expect(sortered_array[1].preevent_items_count).to eq(1)
    expect(sortered_array[1].get_product_category).to eq("Voucher")
    expect(sortered_array[2].preevent_items_count).to eq(1)
    expect(sortered_array[2].get_product_category).to eq("Voucher")
    expect(sortered_array[3].preevent_items_count).to eq(1)
    expect(sortered_array[3].get_product_category).to eq("CredentialType")
    expect(sortered_array[4].preevent_items_count).to eq(2)
    expect(sortered_array[4].get_product_category).to eq("Pack")
    expect(sortered_array[5].preevent_items_count).to eq(3)
    expect(sortered_array[5].get_product_category).to eq("Pack")
    expect(sortered_array[6].preevent_items_count).to eq(3)
    expect(sortered_array[6].get_product_category).to eq("Pack")
  end

  it "should return an array with the order of the categories that will be used in customer area" do
    expect(PreeventProduct.keys_sortered).to eq(["Credit", "Voucher", "CredentialType", "Pack"])
  end

  it "should return a category depending on its preevent items" do
    @event = create(:event)
    expect(create(:preevent_product, :credit_product, event: @event).get_product_category).to eq("Credit")
    expect(create(:preevent_product, :credential_product, event: @event).get_product_category).to eq("CredentialType")
    expect(create(:preevent_product, :voucher_product, event: @event).get_product_category).to eq("Voucher")
    expect(create(:preevent_product, :full, event: @event).get_product_category).to eq("Pack")
  end

  it "should return true if it has more than one preevent_item" do
    @event = create(:event)
    product_right = create(:preevent_product, :full, event: @event)
    product_wrong = create(:preevent_product, :credential_product, event: @event)

    expect(product_right.is_a_pack?).to be(true)
    expect(product_wrong.is_a_pack?).to be(false)
  end

  it "should return true if it can't be modified because of its content" do
    @event = create(:event)
    product_right = create(:preevent_product, :standard_credit_product, event: @event)
    product_wrong = create(:preevent_product, :credit_product, event: @event)

    expect(product_right.is_immutable?).to be(true)
    expect(product_wrong.is_immutable?).to be(false)
  end
end
