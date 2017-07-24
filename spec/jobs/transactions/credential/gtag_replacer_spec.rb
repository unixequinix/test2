require "rails_helper"

RSpec.describe Transactions::Credential::GtagReplacer, type: :job do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let(:old_gtag) { create(:gtag, event: event, customer: customer) }
  let(:new_gtag) { create(:gtag, event: event, customer: create(:customer, event: event)) }
  let(:worker) { Transactions::Credential::GtagReplacer.new }
  let(:atts) { { gtag_id: new_gtag.id, event_id: event.id, ticket_code: old_gtag.tag_uid } }

  it "actions include gtag_replacement" do
    expect(worker.class::TRIGGERS).to include("gtag_replacement")
  end

  it "creates the replaced gtag if not present" do
    atts[:ticket_code] = SecureRandom.hex(7).upcase
    expect { worker.perform(atts) }.to change(Gtag, :count).by(1)
  end

  it "alerts if new_gtag already had a customer" do
    new_gtag.update customer: create(:customer, event: event, anonymous: false)
    expect(Alert).to receive(:propagate).once
    worker.perform(atts)
  end

  describe ".perform" do
    before { worker.perform(atts) }

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
