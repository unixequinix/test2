# == Schema Information
#
# Table name: pack_catalog_items
#
#  amount          :decimal(8, 2)
#
# Indexes
#
#  index_pack_catalog_items_on_catalog_item_id  (catalog_item_id)
#  index_pack_catalog_items_on_pack_id          (pack_id)
#
# Foreign Keys
#
#  fk_rails_b4c71ddbac  (catalog_item_id => catalog_items.id)
#

require "spec_helper"

RSpec.describe PackCatalogItem, type: :model do
  subject { build(:pack_catalog_item) }

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
