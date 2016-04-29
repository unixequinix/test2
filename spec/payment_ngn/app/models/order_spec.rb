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

RSpec.describe Order, type: :model do
  it { is_expected.to validate_presence_of(:profile) }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:aasm_state) }

  let(:profile) { create(:profile) }
  let(:order) { create(:order_with_items, profile: profile) }

  describe "total" do
    it "returns the total of all the items in the order" do
      expect(order.total).to eq(120.0)
    end
  end

  describe "generate_order_number!" do
    it "should create a new order number" do
      order.generate_order_number!
      day = Date.today.strftime("%y%m%d")

      expect(order.number).to start_with(day)
      expect(order.number).to match(/^[a-f0-9]*$/)
    end
  end

  describe "complete_order" do
    it "should store the time when an order is completed" do
      time_before = order.completed_at.to_i
      order.start_payment
      order.complete
      time_after = order.completed_at.to_i

      expect(time_after).to be > time_before
    end
  end

  describe "total_credits" do
    it "should return the total amount of credits available" do
      event = profile.event
      order.order_items.destroy_all
      2.times do
        pp = create(:catalog_item, :with_credit, event: event)
        order.order_items << create(:order_item, catalog_item: pp, order: order)
      end
      # Amount is set in order_items.rb
      expect(order.total_credits).to eq(9 * 2)
    end
  end
end
