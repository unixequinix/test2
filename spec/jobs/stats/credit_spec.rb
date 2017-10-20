require "rails_helper"

RSpec.describe Stats::Credit, type: :job do
  let(:worker) { Stats::Credit }
  let(:event) { create(:event) }
  let(:transaction) { create(:credit_transaction, action: "topup", event: event, credits: 2.2) }

  describe ".stat_creation" do
    let(:action) { "record_credit" }
    let(:name) { "topup" }

    include_examples "a stat"
  end

  describe "extracting credit values" do
    include_examples "a credit"
  end
end
