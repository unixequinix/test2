require "spec_helper"

RSpec.describe Transactions::Credential::GtagReplacer, type: :job do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let(:replaced_gtag) { create(:gtag, event: event, customer: customer) }
  let(:replacement_gtag) { create(:gtag, event: event) }
  let(:worker) { Transactions::Credential::GtagReplacer.new }
  let(:atts) { { gtag_id: replacement_gtag.id, event_id: event.id, reference: replaced_gtag.tag_uid } }

  it "actions include gtag_replacement" do
    expect(worker.class::TRIGGERS).to include("gtag_replacement")
  end

  it "creates the replaced gtag if not present" do
    atts[:reference] = SecureRandom.hex(7).upcase
    expect { worker.perform(atts) }.to change(Gtag, :count).by(1)
  end

  describe ".perform" do
    before { worker.perform(atts) }

    it "assigns the replacement gtag to the customer if replaced gtag had it" do
      expect(replacement_gtag.reload.customer).to eq(customer)
    end

    it "makes the replaced_gtag inactive" do
      expect(replaced_gtag.reload).not_to be_active
    end

    it "makes the replaced_gtag blocked" do
      expect(replaced_gtag.reload).to be_banned
    end

    it "makes the replacement_gtag active" do
      expect(replacement_gtag.reload).to be_active
    end
  end
end
