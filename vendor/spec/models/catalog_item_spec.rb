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

  describe ".virtual_credits" do
    it "returns 0" do
      expect(subject.virtual_credits).to eq(0)
    end
  end

  describe ".tokens" do
    it "returns 0" do
      expect(subject.tokens).to eq(0)
    end
  end

  describe "currencies validation" do
    before do
      subject.update(type: 'Credit')
    end

    it "should not allow delete currency if event is already running" do
      expect { subject.destroy }.to_not change(CatalogItem, :count)
    end

    it "should raise error" do
      subject.destroy
      expect(subject.errors[:base]).to include("cannot delete currency during event")
    end
  end
end
