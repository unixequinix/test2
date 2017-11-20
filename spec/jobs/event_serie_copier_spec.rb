require "rails_helper"

RSpec.describe EventSerieCopier, type: :job do
  let(:worker) { EventSerieCopier }
  let(:old_event) { create(:event) }
  let(:new_event) { create(:event) }
  let!(:registered_customer) { create(:customer, event: old_event, anonymous: false) }
  let!(:anonymous_customer) { old_event.customers.create! }
  let!(:gtag) { create(:gtag, event: old_event, customer: registered_customer, active: true) }

  context "moving all customers" do
    before(:each) do
      @params = [new_event, old_event, %w[0 1]]
    end

    it "copies customers to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.customers.count }.by(2)
      expect(new_event.customers.pluck(:anonymous).count(true)).to eq(1)
      expect(new_event.customers.pluck(:anonymous).count(false)).to eq(1)
    end

    it "copies gtags to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.gtags.count }.by(1)
    end

    it "adds balances to customers" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      expect { worker.perform_now(*@params) }.to change { new_event.orders.count }.by(1)
    end

    it "creates order in new event with expected value for registered_customers" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      worker.perform_now(*@params)
      expect(registered_customer.global_refundable_credits).to eql(5.to_f)
    end

    it "creates order in new event with expected value for anonymous_customers" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      worker.perform_now(*@params)
      expect(anonymous_customer.global_refundable_credits).to eql(0.to_f)
    end
  end

  context "registered customers" do
    before(:each) do
      @params = [new_event, old_event, "0"]
    end

    it "copy registered customers to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.customers.count }.by(1)
    end

    it "copy gtag from registered customers to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.gtags.count }.by(1)
    end

    it "create order in new event" do
      gtag.update! credits: 10, refundable_credits: 5
      expect { worker.perform_now(*@params) }.to change { new_event.orders.count }.by(1)
    end

    it "create order in new event with expected value" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      worker.perform_now(*@params)
      expect(registered_customer.global_refundable_credits).to eql(5.to_f)
    end
  end

  context "moving anonymous customers" do
    before(:each) do
      @params = [new_event, old_event, "1"]
    end

    it "does them individually" do
      old_event.customers.create!
      old_event.customers.create!
      expect { worker.perform_now(*@params) }.to change { new_event.customers.count }.by(3)
      expect(new_event.customers.pluck(:anonymous).count(true)).to eq(3)
    end

    it "copies registered customers to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.customers.count }.by(1)
    end

    it "copies gtag from registered customers to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.gtags.count }.by(0)
    end

    it "creates order in new event" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      expect { worker.perform_now(*@params) }.to change { new_event.orders.count }.by(0)
    end

    it "creates order in new event with expected value" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      worker.perform_now(*@params)
      expect(anonymous_customer.global_refundable_credits).to eql(0.to_f)
    end
  end
end
