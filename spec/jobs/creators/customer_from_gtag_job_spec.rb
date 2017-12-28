require 'rails_helper'

RSpec.describe Creators::CustomerFromGtagJob, type: :job do
  let(:worker) { Creators::CustomerFromGtagJob }
  let(:old_event) { create(:event) }
  let(:old_customer) { create(:customer, event: old_event, anonymous: false) }
  let(:old_gtag) { create(:gtag, event: old_event, customer: old_customer, active: true) }
  let(:event) { create(:event) }

  context "creating gtag" do
    it "can create a gtag" do
      expect { worker.perform_now(old_gtag, event) }.to change { event.gtags.count }.by(1)
    end
    it "can update a gtag of customer" do
      expect { worker.perform_now(old_gtag, event) }.to change { old_customer.gtags.count }.by(1)
    end
    it "can create a customer with new gtag" do
      old_customer.anonymous = true
      old_customer.save!
      expect { worker.perform_now(old_gtag, event) }.to change { event.customers.count }.by(1)
    end
  end
  context "creating orders" do
    it "can create order" do
      old_gtag.credits = 10.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event) }.to change { event.orders.count }.by(1)
    end
    it "can't create order without credtis" do
      old_gtag.credits = 0.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event) }.not_to change(Order, :count)
    end
  end
end
