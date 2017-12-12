require 'rails_helper'

RSpec.describe Creators::OrderJob, type: :job do
  let(:worker) { Creators::OrderJob }
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event, anonymous: false) }
  let(:balance) { rand(100) }
  let(:order) { create(:order, event: event, customer: customer) }

  context "creating order" do
    before { customer.build_order([[event.credit.id, balance]]).complete!("unknown") }
    it "can create an order" do
      expect { worker.perform_now(event, customer, balance) }.to change { event.orders.count }.by(1)
    end
    it "cannot create an order with previous gateway" do
      expect { worker.perform_now(event, customer, balance, "unknown") }.not_to change(Order, :count)
    end
    it "cannot create an order without sufficient funds" do
      balance = 0
      expect { worker.perform_now(event, customer, balance) }.not_to change(Order, :count)
    end
  end
end