# == Schema Information
#
# Table name: orders
#
#  id           :integer          not null, primary key
#  customer_id  :integer          not null
#  number       :string           not null
#  aasm_state   :string           not null
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require "rails_helper"

RSpec.describe Order, type: :model do
  it { is_expected.to validate_presence_of(:customer_event_profile) }
  it { is_expected.to validate_presence_of(:order_items) }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:aasm_state) }

  describe "total" do
    it "returns the total of all the items in the order" do
      order = create(:order)

      expect(order.total).to eq(99.75)
    end
  end

  describe "generate_order_number!" do
    it "should create a new order number" do
      order = create(:order)
      order.generate_order_number!
      day = Date.today.strftime('%y%m%d')

      expect(order.number).to start_with(day)
      expect(order.number).to match(/^[a-f0-9]*$/)
    end
  end

  describe "complete_order" do
    it "should store the time when an order is completed" do
      order = create(:order)
      time_before = order.completed_at.to_i
      order.start_payment
      order.complete
      time_after = order.completed_at.to_i

      expect(time_after).to be > time_before
    end
  end

end
