require "rails_helper"

RSpec.describe Pokes::Money, type: :job do
  let(:worker) { Pokes::Money }
  let(:event) { create(:event) }
  let(:transaction) { create(:money_transaction, action: "onsite_topup", event: event, price: 22) }

  describe ".stat_creation" do
    let(:action) { "topup" }
    let(:name) { nil }

    include_examples "a poke"

    it "removes _onsite from refund action" do
      transaction.update!(action: "onsite_refund")
      poke = worker.perform_now(transaction)
      expect(poke.action).to eql("refund")
    end

    it "removes _online from refund action" do
      transaction.update!(action: "online_refund")
      poke = worker.perform_now(transaction)
      expect(poke.action).to eql("refund")
    end
  end

  describe "extracting monetary info" do
    include_examples "a money"

    it "sets the payment_method of the transaction" do
      transaction.update!(payment_method: "test")
      poke = worker.perform_now(transaction)
      expect(poke.payment_method).to eql("test")
    end
  end
end
