# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  number                    :string           not null
#  aasm_state                :string           not null
#  completed_at              :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  profile_id :integer
#

require "rails_helper"
include ActionView::Helpers::NumberHelper

RSpec.describe Order, type: :model do
  let(:event) { create(:event) }
  let(:profile) { create(:profile, event: event) }
  let(:order) { create(:order_with_items, profile: profile) }

  before { allow(event).to receive(:get_parameter).and_return(100) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:profile) }
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:aasm_state) }

    it "should fail if profile has reached the limit of credits in event settings" do
      allow(profile).to receive(:credits).and_return(100)
      allow(order).to receive(:total_credits).and_return(100)
      expect(order).not_to be_valid
    end
  end

  describe ".total" do
    it "returns the total of all the items in the order" do
      expect(order.total).to eq(order.order_items.to_a.sum(&:total))
    end
  end

  describe ".generate_order_number!" do
    it "should create a new order number" do
      order.generate_order_number!
      expect(order.number).not_to be_nil
    end
  end

  describe ".generate_token" do
    it "is different for different seconds" do
      allow(Time.zone).to receive(:now).and_return(Time.zone.now)
      allow(Time.zone.now).to receive(:strftime).and_return("161005140046599")
      token1 = Order.generate_token
      allow(Time.zone.now).to receive(:strftime).and_return("161005140046600")
      token2 = Order.generate_token

      expect(token1).not_to eq(token2)
    end

    it "is hexadecimal" do
      expect(Order.generate_token).to match(/^[a-f0-9]*$/)
    end

    it "doesn't have more than 12 characters length" do
      expect(Order.generate_token.size < 13).to be_truthy
    end
  end

  describe ".complete_order" do
    it "should store the time when an order is completed" do
      time_before = order.completed_at.to_i
      order.start_payment
      order.complete!
      time_after = order.completed_at.to_i

      expect(time_after).to be > time_before
    end
  end

  describe ".total_credits" do
    it "should return the total amount of credits available" do
      order.order_items.destroy_all
      pp = create(:catalog_item, :with_credit, event: event)
      order.order_items << create(:order_item, catalog_item: pp, order: order)
      order.reload
      expect(order.total_credits).to eq(order.order_items.to_a.sum(&:credits))
    end
  end

  describe ".total_formated" do
    it "returns total formated with two decimals" do
      expect(order.total_formated).to eq(number_with_precision(order.total.round(2), precision: 2))
    end
  end
end
