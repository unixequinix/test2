require 'rails_helper'

RSpec.describe Creators::CustomerJob, type: :job do
  let(:worker) { Creators::CustomerJob }
  let(:event) { create(:event) }
  let(:old_customer) { create(:customer, event: event, anonymous: false) }
  let(:gtag) { create(:gtag, event: event, customer: old_customer, active: true) }
  let!(:initial_topup_flag) { create(:user_flag, event: event, name: 'initial_topup') }

  context "copying customer" do
    it "can copy customer" do
      expect { worker.perform_now(old_customer, event, "0", "0") }.to change { event.customers.count }.by(1)
    end
    it "can add balances to customer" do
      gtag.credits = 5.to_f
      gtag.save!
      expect { worker.perform_now(old_customer, event, "0", "0") }.to change { old_customer.credits }.by(5)
    end
  end
  context "creating orders" do
    it "can create order with credits and virtual" do
      gtag.credits = 10.to_f
      gtag.credits = 5.to_f
      gtag.virtual_credits = 5.to_f

      gtag.save!
      expect { worker.perform_now(old_customer, event, "1", "0") }.to change { event.orders.count }.by(1)
      expect(event.orders.last.virtual_credits).to eq(5.to_f)
    end
    it "can create order with credits and virtual but not virtual" do
      gtag.credits = 10.to_f
      gtag.credits = 5.to_f
      gtag.virtual_credits = 5.to_f

      gtag.save!
      expect { worker.perform_now(old_customer, event, "0", "0") }.to change { event.orders.count }.by(1)
      expect(event.orders.last.virtual_credits).to eq(0.to_f)
    end
    it "can create order with virtual" do
      gtag.virtual_credits = 5.to_f

      gtag.save!
      expect { worker.perform_now(old_customer, event, "1", "0") }.to change { event.orders.count }.by(1)
      expect(event.orders.last.virtual_credits).to eq(5.to_f)
    end
    it "can create order with initial topup" do
      create(:poke, action: 'fee', description: 'initial', event: old_customer.event, customer: old_customer)
      old_customer.update(initial_topup_fee_paid: true)

      expect { worker.perform_now(old_customer, event, "0", "1") }.to change { event.orders.count }.by(1)
      expect(event.orders.last.order_items.first.catalog_item).to eq(initial_topup_flag)
    end
    it "can't create order with initial topup" do
      create(:poke, action: 'fee', description: 'initial', event: old_customer.event, customer: old_customer)
      old_customer.update(initial_topup_fee_paid: false)

      expect { worker.perform_now(old_customer, event, "0", "0") }.to change { event.orders.count }.by(0)
    end
    it "can't create order with virtual" do
      gtag.virtual_credits = 5.to_f

      gtag.save!
      expect { worker.perform_now(old_customer, event, "0", "0") }.to change { event.orders.count }.by(0)
    end
    it "can't create order without credits" do
      gtag.credits = 0.to_f
      gtag.virtual_credits = 0.to_f
      gtag.save!
      expect { worker.perform_now(old_customer, event, "0", "0") }.not_to change(Order, :count)
      expect { worker.perform_now(old_customer, event, "1", "0") }.not_to change(Order, :count)
    end
  end
end
