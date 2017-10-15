require "rails_helper"

RSpec.describe Stats::Money, type: :job do
  let(:worker) { Stats::Money }
  let(:event) { create(:event) }
  let(:transaction) { create(:money_transaction, action: "onsite_topup", event: event, price: 22) }

  describe ".stat_creation" do
    let(:action) { "topup" }
    let(:name) { nil }

    include_examples "a stat"

    it "removes _onsite from refund action" do
      transaction.update!(action: "onsite_refund")
      stat = worker.perform_now(transaction.id)
      expect(stat.action).to eql("refund")
    end

    it "removes _online from refund action" do
      transaction.update!(action: "online_refund")
      stat = worker.perform_now(transaction.id)
      expect(stat.action).to eql("refund")
    end
  end

  describe "extracting monetary info" do
    include_examples "a money"

    it "sets the payment_method of the transaction" do
      transaction.update!(payment_method: "test")
      stat = worker.perform_now(transaction.id)
      expect(stat.payment_method).to eql("test")
    end

    it "sets the currency of the event" do
      stat = worker.perform_now(transaction.id)
      expect(stat.currency).to eql(event.currency)
    end
  end
end
