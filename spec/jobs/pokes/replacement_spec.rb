require "rails_helper"

RSpec.describe Pokes::Replacement, type: :job do
  let(:worker) { Pokes::Replacement }
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let(:old_gtag) { create(:gtag, event: event, customer: customer) }
  let(:new_gtag) { create(:gtag, event: event, customer: create(:customer, event: event)) }
  let(:transaction) { create(:credential_transaction, event: event, gtag: new_gtag, ticket_code: old_gtag.tag_uid) }

  describe ".stat_creation" do
    let(:action) { "replacement" }
    let(:name) { "gtag" }

    include_examples "a poke"
  end

  describe "extracting credential information" do
    let(:credential) { old_gtag }

    include_examples "a credentiable"
  end

  it "actions include gtag_replacement" do
    expect(worker::TRIGGERS).to include("gtag_replacement")
  end

  it "creates the replaced gtag if not present" do
    transaction.update!(ticket_code: SecureRandom.hex(7).upcase)
    expect { worker.perform_now(transaction) }.to change(Gtag, :count).by(1)
  end

  it "alerts if new_gtag already had a registered customer" do
    new_gtag.update! customer: create(:customer, event: event, anonymous: false)
    expect(Alert).to receive(:propagate).once
    worker.perform_now(transaction)
  end

  describe ".perform" do
    before { worker.perform_now(transaction) }

    it "assigns the replacement gtag to the customer if replaced gtag had it" do
      expect(new_gtag.reload.customer).to eq(customer)
    end

    it "makes the old_gtag inactive" do
      expect(old_gtag.reload).not_to be_active
    end

    it "makes the old_gtag blocked" do
      expect(old_gtag.reload).to be_banned
    end

    it "makes the new_gtag active" do
      expect(new_gtag.reload).to be_active
    end
  end
end
