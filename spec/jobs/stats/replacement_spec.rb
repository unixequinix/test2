require "rails_helper"

RSpec.describe Stats::Replacement, type: :job do
  let(:worker) { Stats::Replacement }
  let(:event) { create(:event) }
  let(:new_gtag) { create(:gtag, event: event) }
  let(:old_gtag) { create(:gtag, event: event) }
  let(:transaction) { create(:credential_transaction, action: "gtag_replacement", event: event, gtag: new_gtag, ticket_code: old_gtag.tag_uid) }

  describe ".stat_creation" do
    let(:action) { "replacement" }
    let(:name) { "gtag" }

    include_examples "a stat"
  end

  describe "extracting credential information" do
    let(:credential) { old_gtag }

    include_examples "a credentiable"
  end
end
