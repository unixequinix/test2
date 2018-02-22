require "rails_helper"

RSpec.describe OrderItem, type: :model do
  subject { build(:order_item) }

  it "should be redeemed false by default" do
    expect(OrderItem.new).not_to be_redeemed
  end

  describe ".credits" do
    it "returns the credits of the order_item" do
      subject.catalog_item = build(:credit)
      subject.amount = 50
      expect(subject.credits).to eq(50)
    end
  end

  describe ".virtual_credits" do
    context "when catalog_item is not a pack" do
      it "returns credits" do
        subject.catalog_item = build(:credit)
        subject.amount = 99
        expect(subject.virtual_credits).to eq(subject.virtual_credits)
      end
    end

    context "when catalog_item is a pack" do
      it "returns virtual credits of pack" do
        pack = create(:pack, :with_credit)
        pack.pack_catalog_items.create(catalog_item: pack.event.virtual_credit, amount: 5)
        subject.catalog_item = pack
        subject.amount = 2
        expect(subject.virtual_credits.to_f).to eq(10)
      end
    end
  end
end
