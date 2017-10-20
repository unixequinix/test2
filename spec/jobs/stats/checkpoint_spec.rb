require "rails_helper"

RSpec.describe Stats::Checkpoint, type: :job do
  let(:worker) { Stats::Checkpoint }
  let(:event) { create(:event) }
  let(:access) { create(:access, event: event) }
  let(:transaction) { create(:access_transaction, action: "access_checkpoint", event: event, direction: 1, access: access) }

  describe ".stat_creation" do
    let(:action) { "checkpoint" }
    let(:name) { nil }

    include_examples "a stat"
  end

  describe "extracting checkpoint values" do
    it "sets direction to transactions direction" do
      stat = worker.perform_now(transaction.id)
      expect(stat.access_direction).to eql(transaction.direction)
    end

    it "sets catalog_item_id to that of access" do
      stat = worker.perform_now(transaction.id)
      expect(stat.catalog_item_id).not_to be_nil
      expect(stat.catalog_item_id).to eql(access.id)
    end

    it "sets catalog_item_name to that of access" do
      stat = worker.perform_now(transaction.id)
      expect(stat.catalog_item_name).not_to be_nil
      expect(stat.catalog_item_name).to eql(access.name)
    end

    it "sets catalog_item_type to that of access" do
      stat = worker.perform_now(transaction.id)
      expect(stat.catalog_item_type).not_to be_nil
      expect(stat.catalog_item_type).to eql("Access")
    end
  end
end
