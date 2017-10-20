require "rails_helper"

RSpec.describe Stats::Message, type: :job do
  let(:worker) { Stats::Message }
  let(:event) { create(:event) }
  let(:access) { create(:access, event: event) }
  let(:transaction) { create(:user_engagement_transaction, action: "exhibitor_note", event: event, message: "foo", priority: 5) }

  describe ".stat_creation" do
    let(:action) { "exhibitor_note" }
    let(:name) { nil }

    include_examples "a stat"
  end

  describe "extracting message info" do
    it "sets message to transaction message" do
      stat = worker.perform_now(transaction.id)
      expect(stat.message).to eql(transaction.message)
    end

    it "sets priority to transaction priority" do
      stat = worker.perform_now(transaction.id)
      expect(stat.priority).to eql(transaction.priority)
    end
  end
end
