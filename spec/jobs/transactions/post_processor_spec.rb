require "rails_helper"

RSpec.describe Transactions::PostProcessor, type: :job do
  let(:base)  { Transactions::PostProcessor.new }
  let(:event) { create(:event) }
  let(:gtag)  { create(:gtag, tag_uid: "12345678", event: event) }
  let(:customer) { create(:customer, event: event) }
  let(:transaction) { create(:credit_transaction, event: event, customer_tag_uid: gtag.tag_uid) }

  describe ".apply_customers" do
    it "if not present in neither, creates one" do
      expect { base.perform(transaction) }.to change(Customer, :count).by(1)
    end

    it "if not present in gtag but present in transactions, uses transactions" do
      transaction.update! customer_id: customer.id
      expect { base.perform(transaction) }.to change { gtag.reload.customer }.from(nil).to(customer)
    end

    it "if not present in transaction but present in gtag, uses gtags" do
      gtag.update! customer: customer
      expect { base.perform(transaction) }.not_to change(gtag.reload, :customer)
    end

    it "and adds customer_id to transaction" do
      gtag.update! customer: customer
      expect { base.perform(transaction) }.to change { customer.reload.transactions.count }.from(0).to(1)
    end

    it "assigns any customer to the gtag not matter what" do
      expect { base.perform(transaction) }.to change { gtag.reload.customer }.from(nil)
    end
  end

  it "does not create a Gtag when tag_uid is present in DB" do
    event.gtags << gtag
    expect { base.perform(transaction) }.not_to change(Gtag, :count)
  end

  it "creates a Gtag for the event when tag_uid is not present in DB" do
    transaction.update! customer_tag_uid: "BBBBBBBBBBBBBB"
    expect { base.perform(transaction) }.to change(Gtag, :count).by(1)
  end
end
