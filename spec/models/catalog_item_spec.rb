require "rails_helper"

RSpec.describe CatalogItem, type: :model do
  subject { build(:catalog_item) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".credits" do
    it "returns 0" do
      expect(subject.credits).to eq(0)
    end
  end
end
