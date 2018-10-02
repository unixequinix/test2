require "rails_helper"

RSpec.describe PackCatalogItem, type: :model do
  let(:event) { create(:event) }
  let(:pack) { create(:pack, :with_credit, event: event) }
  subject { create(:pack_catalog_item, pack: pack) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".calculate_maximum_amount" do
    it "should be the maximum_gtag_balance of the event if the catalog_item is a Credit" do
      subject.catalog_item = event.credit
      subject.amount = event.maximum_gtag_balance + 1
      expect(subject).not_to be_valid
      expect(subject.errors[:amount]).to include("must be less than or equal to #{event.maximum_gtag_balance}")
    end

    it "should be the maximum_gtag_virtual_balance of the event if the catalog_item is a VirtualCredit" do
      subject.catalog_item = event.virtual_credit
      subject.amount = event.maximum_gtag_virtual_balance + 1
      expect(subject).not_to be_valid
      expect(subject.errors[:amount]).to include("must be less than or equal to #{event.maximum_gtag_virtual_balance}")
    end

    it "should be 127 if the catalog_item is a counter Access" do
      subject.catalog_item = create(:access, event: event, mode: Access::COUNTER)
      subject.amount = 128
      expect(subject).not_to be_valid
      expect(subject.errors[:amount]).to include("must be less than or equal to 127")
    end

    it "should be 127 if the catalog_item is an infinite Access" do
      subject.catalog_item = create(:access, event: event, mode: Access::PERMANENT)
      subject.amount = 2
      expect(subject).not_to be_valid
      expect(subject.errors[:amount]).to include("must be less than or equal to 1")
    end

    it "should be 1 if the catalog_item is a OperatorPermission" do
      subject.catalog_item = create(:operator_permission, event: event, group: 0)
      subject.amount = 2
      expect(subject).not_to be_valid
      expect(subject.errors[:amount]).to include("must be less than or equal to 1")
    end
  end

  describe ".packception" do
    it "returns an error if the catalog_item is a pack" do
      subject.catalog_item = build(:pack)
      expect(subject).not_to be_valid
    end
  end

  describe ".limit_amount" do
    it "validates the amount if the catalog_item is infinite" do
      subject.catalog_item = build(:access)
      subject.amount = 10
      allow(subject.catalog_item).to receive(:infinite?).and_return(true)
      expect(subject).not_to be_valid
    end
  end
end
