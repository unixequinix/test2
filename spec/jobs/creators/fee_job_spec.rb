require 'rails_helper'

RSpec.describe Creators::FeeJob, type: :job do
  let(:worker) { Creators::FeeJob }
  let(:old_event) { create(:event) }
  let(:event) { create(:event) }
  let!(:initial_topup_flag) { create(:user_flag, event: event, name: 'initial_topup') }
  let(:customer) { create(:customer, event: event, anonymous: false) }
  let(:balance) { rand(100) }

  context "creating fee" do
    before :each do
      create(:poke, action: 'fee', description: 'initial', event: old_event, customer: customer)
    end

    it "can create an order" do
      expect { worker.perform_now(event, customer) }.to change { event.orders.count }.by(1)
    end

    it "can create an order with user flag" do
      worker.perform_now(event, customer)
      expect(event.orders.last.order_items.first.catalog_item).to eq(initial_topup_flag)
    end

    it "cannot create an order with previous gateway" do
      expect { worker.perform_now(event, customer) }.to change(Order, :count).by(1)
      expect { worker.perform_now(event, customer) }.not_to change(Order, :count)
    end
  end
end
