require "rails_helper"

RSpec.describe Transactions::PostProcessor, type: :job do
  let(:base)  { Transactions::PostProcessor.new }
  let(:event) { create(:event) }
  let(:gtag)  { create(:gtag, tag_uid: "12345678", event: event) }
  let(:customer) { create(:customer, event: event) }
  let(:transaction) { create(:credit_transaction, event: event, customer_tag_uid: gtag.tag_uid) }
  let(:atts) { { transaction_id: transaction.id, event_id: event.id, customer_tag_uid: gtag.tag_uid } }

  it "calls ticket validator perform if action is ticket_validation and there is no gtag" do
    atts[:action] = "ticket_validation"
    expect(Transactions::Credential::TicketValidator).to receive(:perform_later).once.with(atts)
    base.perform(atts)
  end

  describe ".apply_customers" do
    it "if not present in neither, creates one" do
      expect { base.perform(atts) }.to change(Customer, :count).by(1)
    end

    it "if not present in gtag but present in transactions, uses transactions" do
      transaction.update! customer_id: customer.id
      expect { base.perform(atts) }.to change { gtag.reload.customer }.from(nil).to(customer)
    end

    it "if not present in transaction but present in gtag, uses gtags" do
      gtag.update! customer: customer
      expect { base.perform(atts) }.not_to change(gtag.reload, :customer)
    end

    it "and adds customer_id to transaction" do
      gtag.update! customer: customer
      expect { base.perform(atts) }.to change { customer.reload.transactions.count }.from(0).to(1)
    end

    it "assigns any customer to the gtag not matter what" do
      expect { base.perform(atts) }.to change { gtag.reload.customer }.from(nil)
    end
  end

  describe ".create_gtag" do
    it "does not create a Gtag when tag_uid is present in DB" do
      event.gtags << gtag
      expect { base.perform(atts) }.not_to change(Gtag, :count)
    end

    it "creates a Gtag for the event when tag_uid is not present in DB" do
      transaction.update! customer_tag_uid: "BBBBBBBBBBBBBB"
      expect { base.perform(atts) }.to change(Gtag, :count).by(1)
    end
  end

  describe "executing operations" do
    before { atts[:action] = "sale" }
    before { allow(Stats::Sale).to receive(:perform_later) }

    it "executes tasks based on triggers" do
      expect(Transactions::Credit::BalanceUpdater).to receive(:perform_later).once
      base.perform(atts)
    end

    it "does not execute operations if status code is not 0" do
      transaction.update!(status_code: 2)
      expect(Transactions::Credit::BalanceUpdater).not_to receive(:perform_later)
      base.perform(atts)
    end
  end
end
