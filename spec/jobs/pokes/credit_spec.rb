require "rails_helper"

RSpec.describe Pokes::Credit, type: :job do
  let(:worker) { Pokes::Credit }
  let(:event) { create(:event) }
  let(:payment) { { event.credit.id.to_s => { "credit_name" => event.credit.name, "credit_value" => event.credit.value, "amount" => 2.2 } } }
  let(:transaction) { create(:credit_transaction, action: "topup", event: event, payments: payment) }

  describe ".stat_creation" do
    let(:action) { "record_credit" }
    let(:name) { "topup" }

    include_examples "a poke"
  end

  describe "resolving description" do
    it "sets the description to checkin if station category is check_in and action is topup" do
      allow(transaction.station).to receive(:category).and_return("check_in")
      expect(worker.perform_now(transaction).first.description).to eql("checkin")
    end

    it "sets the description to purchase if station category is box_office and action is topup" do
      allow(transaction.station).to receive(:category).and_return("box_office")
      expect(worker.perform_now(transaction).first.description).to eql("purchase")
    end

    it "removes _fee from description if action is in FEES" do
      description = Pokes::Credit::FEES.sample
      transaction.update!(action: description)
      expect(worker.perform_now(transaction).first.description).to eql(description.gsub("_fee", ""))
    end
  end

  describe "resolving action" do
    it "sets the action to purchase if action is in FEES" do
      transaction.update!(action: Pokes::Credit::FEES.sample)
      expect(worker.perform_now(transaction).first.action).to eql("fee")
    end

    it "sets the action to correction if action is in CORRECTIONS" do
      transaction.update!(action: Pokes::Credit::CORRECTIONS.sample)
      expect(worker.perform_now(transaction).first.action).to eql("correction")
    end

    it "sets the action to record_credit if action in ACTIONS" do
      transaction.update!(action: Pokes::Credit::ACTIONS.sample)
      expect(worker.perform_now(transaction).first.action).to eql("record_credit")
    end
  end

  describe "extracting credit values" do
    include_examples "a credit"

    it "sets credit_amount to one of transaction" do
      expect(@poke.credit_amount).to eql(2.2)
    end
  end
end
