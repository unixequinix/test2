require "rails_helper"

RSpec.describe Pokes::Checkin, type: :job do
  let(:worker) { Pokes::Checkin }
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event) }
  let(:transaction) { create(:credential_transaction, action: "ticket_checkin", event: event, ticket: ticket) }

  describe ".stat_creation" do
    let(:action) { "checkin" }
    let(:name) { "ticket" }

    include_examples "a poke"
  end

  it "marks ticket redeemed" do
    expect { worker.perform_now(transaction) }.to change { ticket.reload.redeemed? }.from(false).to(true)
  end

  it "propagates alert if ticket is already redeemed" do
    ticket.update(redeemed: true)
    expect(Alert).to receive(:propagate).once
    worker.perform_now(transaction)
  end

  describe "when processing tickets" do
    let(:credential) { ticket }
    let(:catalog_item) { credential.ticket_type.catalog_item }

    include_examples "a catalog_item"
    include_examples "a ticket_type"
    include_examples "a credentiable"

    it "assigns the ticket to the poke for ticket actions" do
      transaction.update!(action: %w[ticket_checkin ticket_validation].sample)
      poke = worker.perform_now(transaction)
      expect(poke.credential).to eql(ticket)
    end

    it "assigns the ticket to the poke for gtag actions" do
      gtag = create(:gtag, event: event)
      transaction.update!(action: %w[gtag_checkin].sample, gtag: gtag)
      poke = worker.perform_now(transaction)
      expect(poke.credential).to eq(gtag)
    end
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
    let(:transaction) { create(:credential_transaction, action: "ticket_validation", event: event, ticket: ticket, gtag: nil, customer_tag_uid: nil) }

    include_examples "a catalog_item"
    include_examples "a ticket_type"
    include_examples "a credentiable"

    it "sets action to ticket_validation" do
      poke = worker.perform_now(transaction)
      expect(poke.action).to eql("ticket_validation")
    end
  end
end
