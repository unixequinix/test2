require "rails_helper"

RSpec.describe EventSerieCreator, type: :job do
  let(:worker) { EventSerieCreator.new }
  let(:event_serie) { create(:event_serie) }
  let!(:base_event) { create(:event, event_serie: event_serie) }
  let!(:current_event) { create(:event, event_serie: event_serie) }
  let!(:registered_customer) { create(:customer, event: base_event, anonymous: false) }
  let!(:anonymous_customer) { create(:customer, event: base_event) }
  let!(:gtag) { create(:gtag, event: base_event, customer: registered_customer) }

  context "registered_customer" do
    before(:each) do
      @params = [current_event, base_event, false]
    end

    it "copy registered customers to new event" do
      expect { worker.perform(*@params) }.to change { current_event.customers.count }.by(1)
    end

    it "copy gtag from registered customers to new event" do
      expect { worker.perform(*@params) }.to change { current_event.gtags.count }.by(1)
    end

    it "create order in new event" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      expect { worker.perform(*@params) }.to change { current_event.orders.count }.by(1)
    end

    it "create order in new event with expected value" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      worker.perform(*@params)
      expect(registered_customer.global_refundable_credits).to eql(5.to_f)
    end
  end

  context "anonymous_customer" do
    before(:each) do
      @params = [current_event, base_event, true]
    end

    it "copy registered customers to new event" do
      expect { worker.perform(*@params) }.to change { current_event.customers.count }.by(1)
    end

    it "copy gtag from registered customers to new event" do
      expect { worker.perform(*@params) }.to change { current_event.gtags.count }.by(0)
    end

    it "create order in new event" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      expect { worker.perform(*@params) }.to change { current_event.orders.count }.by(0)
    end

    it "create order in new event with expected value" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      worker.perform(*@params)
      expect(anonymous_customer.global_refundable_credits).to eql(0.to_f)
    end
  end

  context "all customers" do
    before(:each) do
      @params = [current_event, base_event, nil]
    end

    it "copy registered customers to new event" do
      expect { worker.perform(*@params) }.to change { current_event.customers.count }.by(2)
    end

    it "copy gtag from registered customers to new event" do
      expect { worker.perform(*@params) }.to change { current_event.gtags.count }.by(1)
    end

    it "create order in new event" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      expect { worker.perform(*@params) }.to change { current_event.orders.count }.by(1)
    end

    it "create order in new event with expected value for registered_customers" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      worker.perform(*@params)
      expect(registered_customer.global_refundable_credits).to eql(5.to_f)
    end

    it "create order in new event with expected value for anonymous_customers" do
      gtag.credits = 10.to_f
      gtag.refundable_credits = 5.to_f
      gtag.save!

      worker.perform(*@params)
      expect(anonymous_customer.global_refundable_credits).to eql(0.to_f)
    end
  end
end
