require "rails_helper"

RSpec.describe Stats::Flag, type: :job do
  let(:worker) { Stats::Flag }
  let(:event) { create(:event) }
  let(:flag) { create(:user_flag, event: event, name: "banned") }
  let(:transaction) { create(:user_flag_transaction, action: "user_flag", event: event, user_flag: "banned", user_flag_active: true) }

  before { flag }

  describe ".stat_creation" do
    let(:action) { "user_flag" }
    let(:name) { nil }

    include_examples "a stat"
  end

  describe "extracting user flag info" do
    it "sets user_flag_value to transactions one" do
      stat = worker.perform_now(transaction.id)
      expect(stat.user_flag_value).to eql(transaction.user_flag_active)
    end

    it "setting catalog_item_id to that of flag" do
      stat = worker.perform_now(transaction.id)
      expect(stat.catalog_item_id).not_to be_nil
      expect(stat.catalog_item_id).to eql(flag.id)
    end

    it "setting catalog_item_name to that of flag" do
      stat = worker.perform_now(transaction.id)
      expect(stat.catalog_item_name).not_to be_nil
      expect(stat.catalog_item_name).to eql(flag.name)
    end

    it "setting catalog_item_type to that of flag" do
      stat = worker.perform_now(transaction.id)
      expect(stat.catalog_item_type).not_to be_nil
      expect(stat.catalog_item_type).to eql(flag.class.to_s)
    end
  end
end
