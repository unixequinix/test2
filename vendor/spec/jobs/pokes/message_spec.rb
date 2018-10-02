require "rails_helper"

RSpec.describe Pokes::Message, type: :job do
  let(:worker) { Pokes::Message }
  let(:event) { create(:event) }
  let(:access) { create(:access, event: event) }
  let(:transaction) { create(:user_engagement_transaction, action: "exhibitor_note", event: event, message: "foo", priority: 5) }

  describe ".stat_creation" do
    let(:action) { "exhibitor_note" }
    let(:name) { nil }

    include_examples "a poke"
  end

  describe "extracting message info" do
    it "sets message to transaction message" do
      poke = worker.perform_now(transaction)
      expect(poke.message).to eql(transaction.message)
    end

    it "sets priority to transaction priority" do
      poke = worker.perform_now(transaction)
      expect(poke.priority).to eql(transaction.priority)
    end
  end
end
