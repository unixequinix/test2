require 'rails_helper'

# rubocop:disable all
RSpec.describe Creators::CustomerFromGtagJob, type: :job do
  let(:worker) { Creators::CustomerFromGtagJob }
  let(:old_event) { create(:event) }
  let(:old_customer) { create(:customer, event: old_event, anonymous: false) }
  let(:old_gtag) { create(:gtag, event: old_event, customer: old_customer, active: true) }
  let(:event) { create(:event) }
  let!(:initial_topup_flag) { create(:user_flag, event: event, name: 'initial_topup') }

  context "creating gtag" do
    it "can create a gtag" do
      expect { worker.perform_now(old_gtag, event, "0", "0") }.to change { event.gtags.count }.by(1)
    end
    it "can update a gtag of customer" do
      expect { worker.perform_now(old_gtag, event, "0", "0") }.to change { old_customer.gtags.count }.by(1)
    end
    it "can create a customer with new gtag" do
      old_customer.anonymous = true
      old_customer.save!
      expect { worker.perform_now(old_gtag, event, "0", "0") }.to change { event.customers.count }.by(1)
    end
    it "can create a customer with multiple gtags" do
      create(:gtag, event: old_event, customer: old_customer, active: false, credits:50.to_f, virtual_credits: 10.to_f)
      old_customer.anonymous = true
      old_customer.save!

      expect {
        worker.perform_now(old_gtag, event, "0", "0")
      }.to change { event.customers.count }.by(1)
       .and change { event.gtags.count }.by(2)

      expect(event.gtags.pluck(:customer_id).uniq).to eql(event.customers.pluck(:id).uniq)
    end
  end
  context "creating orders" do
    # Balance
    it "can create order with credits but not virtual" do
      old_gtag.credits = 10.to_f
      old_gtag.virtual_credits = 5.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "0", "0") }.to change { event.orders.count }.by(1)
      expect(event.orders.last.virtual_credits).to eq(0.to_f)
    end
    it "can create order with credits and virtual" do
      old_gtag.credits = 10.to_f
      old_gtag.virtual_credits = 5.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "1", "0") }.to change { event.orders.count }.by(1)
      expect(event.orders.last.virtual_credits).to eq(5.to_f)
    end
    it "can create order with credits" do
      old_gtag.credits = 10.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "0", "0") }.to change { event.orders.count }.by(1)
    end
    it "can create order with credits too" do
      old_gtag.credits = 10.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "1", "0") }.to change { event.orders.count }.by(1)
    end
    it "can't create order with virtual" do
      old_gtag.virtual_credits = 10.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "0", "0") }.to change { event.orders.count }.by(0)
    end
    it "can create order with virtual" do
      old_gtag.virtual_credits = 10.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "1", "0") }.to change { event.orders.count }.by(1)
    end
    it "can't create order without credits" do
      old_gtag.credits = 0.to_f
      old_gtag.save!
      expect { worker.perform_now(old_gtag, event, "0", "0") }.not_to change(Order, :count)
    end

    # Fees
    it "can create order" do
      create(:poke, action: 'fee', description: 'initial', event: old_event, customer: old_customer)
      old_customer.update(initial_topup_fee_paid: true)

      expect { worker.perform_now(old_gtag, event, "0", "1") }.to change { event.orders.count }.by(1)
      expect(event.orders.last.order_items.first.catalog_item).to eq(initial_topup_flag)
    end

    it "can't create order" do
      create(:poke, action: 'fee', description: 'initial', event: old_event, customer: old_customer)
      old_customer.update(initial_topup_fee_paid: false)

      expect { worker.perform_now(old_gtag, event, "0", "0") }.to change { event.orders.count }.by(0)
    end
  end
end
