require 'rails_helper'

RSpec.describe Creators::CustomerFromGtagJob, type: :job do
  let(:worker) { Creators::CustomerFromGtagJob }
  let(:old_event) { create(:event) }
  let(:old_customer) { create(:customer, event: old_event, anonymous: false) }
  let(:old_gtag) { create(:gtag, event: old_event, customer: old_customer, active: true) }
  let(:event) { create(:event) }

  context "creating gtag" do
    it "can create a gtag" do
      expect { worker.perform_now(old_gtag, event, "0") }.to change { event.gtags.count }.by(1)
    end
    it "can update a gtag of customer" do
      expect { worker.perform_now(old_gtag, event, "0") }.to change { old_customer.gtags.count }.by(1)
    end
    it "can create a customer with new gtag" do
      old_customer.anonymous = true
      old_customer.save!
      expect { worker.perform_now(old_gtag, event, "0") }.to change { event.customers.count }.by(1)
    end
  end
  context "creating orders" do
    it "can create order with credits but not virtual" do
      old_gtag.credits = 10.to_f
      old_gtag.virtual_credits = 5.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "0") }.to change { event.orders.count }.by(1)
      expect(event.orders.last.virtual_credits).to eq(0.to_f)
    end
    it "can create order with credits and virtual" do
      old_gtag.credits = 10.to_f
      old_gtag.virtual_credits = 5.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "1") }.to change { event.orders.count }.by(1)
      expect(event.orders.last.virtual_credits).to eq(5.to_f)
    end
    it "can create order with credits" do
      old_gtag.credits = 10.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "0") }.to change { event.orders.count }.by(1)
    end
    it "can create order with credits too" do
      old_gtag.credits = 10.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "1") }.to change { event.orders.count }.by(1)
    end
    it "can't create order with virtual" do
      old_gtag.virtual_credits = 10.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "0") }.to change { event.orders.count }.by(0)
    end
    it "can create order with virtual" do
      old_gtag.virtual_credits = 10.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "1") }.to change { event.orders.count }.by(1)
    end
    it "can't create order without credits" do
      old_gtag.credits = 0.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "0") }.not_to change(Order, :count)
    end
  end
end
