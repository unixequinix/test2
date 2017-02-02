# == Schema Information
#
# Table name: customers
#
#  address                    :string
#  agreed_event_condition     :boolean          default(FALSE)
#  agreed_on_registration     :boolean          default(FALSE)
#  banned                     :boolean
#  birthdate                  :datetime
#  city                       :string
#  country                    :string
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  email                      :citext           default(""), not null
#  encrypted_password         :string           default(""), not null
#  first_name                 :string           default(""), not null
#  gender                     :string
#  last_name                  :string           default(""), not null
#  last_sign_in_at            :datetime
#  last_sign_in_ip            :inet
#  locale                     :string           default("en")
#  phone                      :string
#  postcode                   :string
#  receive_communications     :boolean          default(FALSE)
#  receive_communications_two :boolean          default(FALSE)
#  remember_token             :string
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  sign_in_count              :integer          default(0), not null
#
# Indexes
#
#  index_customers_on_event_id              (event_id)
#  index_customers_on_remember_token        (remember_token) UNIQUE
#  index_customers_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_0b9257e0c6  (event_id => events.id)
#

require "spec_helper"

RSpec.describe Customer, type: :model do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe ".create_order" do
    before do
      @station = create(:station, category: "customer_portal", event: event)
      @accesses = create_list(:access, 2, event: event)
      @items = @accesses.map do |item|
        num = rand(100)
        @station.station_catalog_items.create!(catalog_item: item, price: num)
        [item.id, item.id]
      end
      @order = customer.create_order(@items)
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
          expect(order_item.total).to eq(catalog_item.price * catalog_item.id)
        end
      end

      it "with correct counters" do
        expect(@order_items.map(&:counter).sort).to eq([1, 2])
      end
    end

    describe "on a second run" do
      before do
        @items = @accesses.map { |item| [item.id, item.id] }
        @order = customer.create_order(@items)
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
      %w(customer.foo.com customer@test _@test.).each do |wrong_mail|
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
