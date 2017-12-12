require 'rails_helper'

RSpec.describe Creators::CustomerJob, type: :job do
  let(:worker) { Creators::CustomerJob }
  let(:event) { create(:event) }
  let(:old_customer) { create(:customer, event: event, anonymous: false) }
  let(:gtag) { create(:gtag, event: event, customer: old_customer, active: true) }

  context "copying customer" do
    it "can copy customer" do
      expect { worker.perform_now(old_customer, event) }.to change { event.customers.count }.by(1)
    end
    it "can add balances to customer" do
      gtag.refundable_credits = 5.to_f
      gtag.save!
      expect { worker.perform_now(old_customer, event) }.to change { old_customer.global_refundable_credits }.by(5)
    end
  end
  context "creating orders" do
    it "can create order" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!
      expect { worker.perform_now(old_customer, event) }.to change { event.orders.count }.by(1)
    end
    it "can't create order without credtis" do
      gtag.refundable_credits = 0.to_f
      gtag.save!
      expect { worker.perform_now(old_customer, event) }.not_to change { event.orders.count }
    end
  end
end
