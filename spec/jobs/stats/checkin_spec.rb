require "rails_helper"

RSpec.describe Stats::Checkin, type: :job do
  let(:worker) { Stats::Checkin }
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event) }
  let(:transaction) { create(:credential_transaction, action: "ticket_checkin", event: event, ticket: ticket) }

  describe ".stat_creation" do
    let(:action) { "checkin" }
    let(:name) { "ticket" }

    include_examples "a stat"
  end

  describe "when processing tickets" do
    let(:credential) { ticket }
    let(:catalog_item) { credential.ticket_type.catalog_item }

    include_examples "a catalog_item"
    include_examples "a ticket_type"
    include_examples "a credentiable"
  end

  describe "when processing gtags" do
    let(:credential) { create(:gtag, event: event, ticket_type: create(:ticket_type, event: event)) }
    let(:catalog_item) { credential.ticket_type.catalog_item }
    let(:transaction) { create(:credential_transaction, action: "gtag_checkin", event: event, gtag: credential) }

    include_examples "a catalog_item"
    include_examples "a ticket_type"
    include_examples "a credentiable"
  end

  describe "when processing tickets_validations" do
    let(:credential) { ticket }
    let(:catalog_item) { credential.ticket_type.catalog_item }
    let(:transaction) { create(:credential_transaction, action: "ticket_validation", event: event, ticket: ticket, gtag: nil, customer_tag_uid: nil) } # rubocop:disable Metrics/LineLength

    include_examples "a catalog_item"
    include_examples "a ticket_type"
    include_examples "a credentiable"

    it "sets action to ticket_validation" do
      stat = worker.perform_now(transaction.id)
      expect(stat.action).to eql("ticket_validation")
    end
  end
end
