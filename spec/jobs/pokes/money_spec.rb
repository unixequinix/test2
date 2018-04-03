require "rails_helper"

RSpec.describe Pokes::Money, type: :job do
  let(:worker) { Pokes::Money }
  let(:event) { create(:event) }
  let(:transaction) { create(:money_transaction, action: "onsite_topup", event: event, price: 22) }

  it "does not process transactions with payment_method 'other' and action 'onsite_topup'" do
    transaction.update!(payment_method: "other", action: "onsite_topup")
    expect(worker.perform_now(transaction)).to be_nil
  end

  it "process transactions with payment_method 'other' and any other action" do
    transaction.update!(payment_method: "other", action: "any_other")
    expect(worker.perform_now(transaction)).not_to be_nil
  end

  it "does not process transactions with payment_method 'none' and action 'onsite_topup'" do
    transaction.update!(payment_method: "none", action: "onsite_topup")
    expect(worker.perform_now(transaction)).to be_nil
  end

  it "process transactions with payment_method 'none' and any other action" do
    transaction.update!(payment_method: "none", action: "any_other")
    expect(worker.perform_now(transaction)).not_to be_nil
  end

  it "process transactions with any other payment_method and action 'onsite_topup'" do
    transaction.update!(payment_method: "any other", action: "onsite_topup")
    expect(worker.perform_now(transaction)).not_to be_nil
  end

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
