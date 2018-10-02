require "rails_helper"

RSpec.describe Product, type: :model do
  subject { create(:product) }

  describe "station touch" do
    before(:each) { subject.save }

    it "resets the station updated_at field" do
      expect { subject.update!(position: 10) }.to change(subject.station, :updated_at)
    end
  end

  describe "product prices" do
    it "should have at least one set price" do
      expect(subject).to be_valid
    end

    it "should remove key from field if value is empty or nil" do
      original_prices = subject.prices
      subject.prices = subject.prices.merge(subject.station.event.virtual_credit.id.to_s => '')
      subject.save
      expect(subject.prices).to eq(original_prices)
    end

    it "should raise error without prices" do
      subject.prices = {}
      expect { subject.save }.to_not change(Product, :count)
      expect(subject.errors[:base]).to include("Error: must provide a price for this product")
    end
  end

  describe "product price" do
    before do
      subject.prices[subject.station.event.credit.id.to_s] = { "price" => 9.1 }
    end

    it "is the same as the credit value of prices on save" do
      subject.save!
      expect(subject.price).to eql(9.1)
    end

    it "is the same as the credit value of prices on update" do
      subject.update! prices: { subject.station.event.credit.id.to_s => { "price" => 9.1 } }
      expect(subject.price).to eql(9.1)
    end
  end
end
