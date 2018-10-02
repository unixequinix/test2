require "rails_helper"

RSpec.describe Pokes::Checkpoint, type: :job do
  let(:worker) { Pokes::Checkpoint }
  let(:event) { create(:event) }
  let(:access) { create(:access, event: event) }
  let(:transaction) { create(:access_transaction, action: "access_checkpoint", event: event, direction: 1, access: access) }

  describe ".stat_creation" do
    let(:action) { "checkpoint" }
    let(:name) { nil }

    include_examples "a poke"
  end

  describe "extracting checkpoint values" do
    it "sets direction to the opposite of transactions direction" do
      poke = worker.perform_now(transaction)
      expect(poke.access_direction).to eql(-transaction.direction)
    end

    it "sets catalog_item_id to that of access" do
      poke = worker.perform_now(transaction)
      expect(poke.catalog_item_id).not_to be_nil
      expect(poke.catalog_item_id).to eql(access.id)
    end

    it "sets catalog_item_type to that of access" do
      poke = worker.perform_now(transaction)
      expect(poke.catalog_item_type).not_to be_nil
      expect(poke.catalog_item_type).to eql("Access")
    end
  end
end
