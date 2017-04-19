require "spec_helper"

RSpec.describe Customer, type: :model do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe ".build_order" do
    before do
      @station = create(:station, category: "customer_portal", event: event)
      @accesses = create_list(:access, 2, event: event)
      @items = @accesses.map do |item|
        num = rand(10..100)
        @station.station_catalog_items.create!(catalog_item: item, price: num)
        [item.id, 11]
      end
      @order = customer.build_order(@items)
      expect(@order.save).to be_truthy
    end

    describe "when creating refunds" do
      before { @items = [[@accesses.first.id, -11], [@accesses.first.id, -5]] }

      it "creates order_items with negative total" do
        expect(customer.build_order(@items).order_items.map(&:total).sum).to be_negative
      end

      it "creates order_items with negative amount" do
        expect(customer.build_order(@items).order_items.map(&:amount).sum).to be_negative
      end
    end

    it "creates a valid order" do
      expect(@order).to be_valid
    end

    describe "creates order_items" do
      before { @order_items = @order.order_items }

      it "which are valid" do
        expect(@order_items).not_to be_empty
        @order_items.each { |oi| expect(oi).to be_valid }
      end

      it "with correct price" do
        @order_items.each do |order_item|
          catalog_item = order_item.catalog_item
          expect(order_item.total).to eq(catalog_item.price * 11)
        end
      end

      it "with correct counters" do
        expect(@order_items.map(&:counter).sort).to eq([1, 2])
      end
    end

    describe "on a second run" do
      before do
        @items = @accesses.map { |item| [item.id, 11] }
        @order = customer.build_order(@items)
      end

      it "should add counters" do
        expect(@order.order_items.map(&:counter).sort).to eq([3, 4])
      end
    end
  end

  describe ".full_name" do
    it "return the first_name and last_name together" do
      allow(customer).to receive(:first_name).and_return("Glownet")
      allow(customer).to receive(:last_name).and_return("Test")
      expect(customer.full_name).to eq("Glownet Test")
    end
  end

  context "with a new customer" do
    describe "the phone" do
      it "is not required" do
        customer = Customer.new(phone: "+34660660660")
        customer.valid?
        expect(customer.errors[:phone]).to eq([])
      end
    end

    describe "the email" do
      %w[customer.foo.com customer@test _@test.].each do |wrong_mail|
        it "is invalid if resembles #{wrong_mail}" do
          customer.email = wrong_mail
        end
      end
    end

    describe "the birthdate" do
      it "is a date" do
        expect(customer.birthdate.is_a?(ActiveSupport::TimeWithZone)).to eq(true)
      end
    end
  end
end
