require "rails_helper"

RSpec.describe PackCatalogItem, type: :model do
  let(:pack) { create(:pack, :with_credit) }
  subject { create(:pack_catalog_item, pack: pack) }

  it "has a valid factory" do
    expect(subject).to be_valid
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
