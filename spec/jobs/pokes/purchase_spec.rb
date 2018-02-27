require "rails_helper"

RSpec.describe Pokes::Purchase, type: :job do
  let(:worker) { Pokes::Purchase }
  let(:event) { create(:event) }
  let(:access) { create(:access, event: event) }
  let(:transaction) { create(:money_transaction, action: "box_office_purchase", event: event, catalog_item: access) }

  describe ".stat_creation" do
    let(:action) { "purchase" }
    let(:name) { nil }

    include_examples "a poke"
  end

  describe "extracting purchase information" do
    context "box_office_purchase action, " do
      before { transaction.update action: "box_office_purchase" }
      let(:catalog_item) { transaction.catalog_item }

      include_examples "a catalog_item"
      include_examples "a money"
    end

    it "sets the payment_method of the transaction" do
      transaction.update!(payment_method: "test")
      poke = worker.perform_now(transaction)
      expect(poke.payment_method).to eql("test")
    end
  end
end
