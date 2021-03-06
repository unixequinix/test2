require "rails_helper"

RSpec.describe Creators::EventSerieJob, type: :job do
  let(:worker) { Creators::EventSerieJob }
  let(:old_event) { create(:event) }
  let(:new_event) { create(:event) }
  let!(:registered_customer) { create(:customer, event: old_event, anonymous: false) }
  let!(:anonymous_customer) { old_event.customers.create! }
  let!(:gtag) { create(:gtag, event: old_event, customer: registered_customer, active: true) }
  let!(:anonymous_gtag) { create(:gtag, event: old_event, customer: anonymous_customer, active: true) }
  let!(:initial_topup_flag) { create(:user_flag, event: new_event, name: 'initial_topup') }

  context "comparing events" do
    it "new event has got some base event params" do
      common_attrs = %w[gtag_deposit_fee every_onsite_topup_fee onsite_initial_topup_fee online_initial_topup_fee online_refund_fee refund_minimum]
      common_attrs.each do |attr|
        expect(old_event[attr]).to eq(new_event[attr])
      end
    end
  end

  context "moving gtags" do
    before { create(:gtag, event: old_event, customer: nil) }

    it "can move unused gtags" do
      expect { worker.perform_now(new_event, old_event, %w[0 1], "1") }.to change { new_event.gtags.count }.by(3)
    end

    it "doesn't move unused gtags if not selected" do
      create(:gtag, event: old_event, customer: nil)
      expect { worker.perform_now(new_event, old_event, %w[0 1], "0") }.to change { new_event.gtags.count }.by(2)
    end
  end

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
      expect { worker.perform_now(*@params) }.to change { new_event.gtags.count }.by(2)
    end

    it "adds balances to customers" do
      gtag.update! final_balance: 10, final_virtual_balance: 5

      expect { worker.perform_now(*@params) }.to change { new_event.orders.count }.by(1)
    end

    it "creates order in new event with expected credits for registered_customers" do
      gtag.update! final_balance: 8.to_f
      worker.perform_now(*@params)
      expect(registered_customer.credits).to eql(8.to_f)
    end

    it "creates order in new event with expected virtual_credits for registered_customers" do
      gtag.update! final_virtual_balance: 12.to_f
      worker.perform_now(*@params)
      expect(registered_customer.virtual_credits).to eql(12.to_f)
    end

    it "creates order in new event with expected value for anonymous_customers" do
      gtag.update! final_balance: 10, final_virtual_balance: 5

      worker.perform_now(*@params)
      expect(anonymous_customer.credits).to eql(0.to_f)
    end
  end

  context "registered customers" do
    before(:each) do
      @params = [new_event, old_event, "0"]
    end

    it "copies registered customers with no gtag" do
      create(:customer, event: old_event, anonymous: false)
      expect { worker.perform_now(*@params) }.to change { new_event.customers.count }.by(2)
    end

    it "copies registered customers to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.customers.count }.by(1)
    end

    it "copies gtag from registered customers to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.gtags.count }.by(1)
    end

    it "create order in new event" do
      gtag.update! final_balance: 10, final_virtual_balance: 5
      expect { worker.perform_now(*@params) }.to change { new_event.orders.count }.by(1)
    end

    it "create order in new event with expected value" do
      gtag.update! final_balance: 10, final_virtual_balance: 5

      worker.perform_now(*@params)
      expect(registered_customer.credits).to eql(10.to_f)
    end
  end

  context "moving anonymous customers" do
    before(:each) do
      @params = [new_event, old_event, "1"]
    end

    it "does them individually" do
      create(:gtag, event: old_event, customer: old_event.customers.create!)
      create(:gtag, event: old_event, customer: old_event.customers.create!)
      expect { worker.perform_now(*@params) }.to change { new_event.customers.count }.by(3)
      expect(new_event.customers.pluck(:anonymous).count(true)).to eq(3)
    end

    it "copies anonymous customers to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.customers.count }.by(1)
    end

    it "copies gtag from anonymous customers to new event" do
      expect { worker.perform_now(*@params) }.to change { new_event.gtags.count }.by(1)
    end

    it "creates order in new event" do
      gtag.update! final_balance: 10, final_virtual_balance: 5

      expect { worker.perform_now(*@params) }.to change { new_event.orders.count }.by(0)
    end

    it "creates order in new event with expected value" do
      gtag.update! final_balance: 10, final_virtual_balance: 5

      worker.perform_now(*@params)
      expect(anonymous_customer.credits).to eql(0.to_f)
    end
  end

  context "moving multiple gtags" do
    before { create(:gtag, event: old_event, customer: anonymous_customer, active: false) }

    it "moves to new copied customer" do
      expect { worker.perform_now(new_event, old_event, %w[0 1], "1") }.to change { new_event.gtags.count }.by(3)
      expect(new_event.customers.anonymous.last.gtags.count).to eql(2)
    end
  end

  context "create initial fee orders" do
    before(:each) do
      create(:poke, action: 'fee', description: 'initial', event: old_event, customer: anonymous_customer)
      anonymous_customer.update(initial_topup_fee_paid: true)

      @params = [new_event, old_event, %w[0 1], "0", "0", "1"]
    end

    it "creates initial fee order in new event" do
      worker.perform_now(*@params)

      expect(new_event.orders.count).to eql(1)
    end
  end
end
