require "rails_helper"

RSpec.describe Transactions::Credential::GtagChecker, type: :job do
  let(:event) { create(:event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:transaction) { create(:credential_transaction, event: event, gtag: gtag) }
  let(:worker) { Transactions::Credential::GtagChecker.new }
  let(:atts) { { transaction_id: transaction.id } }

  it "marks gtag redeemed" do
    expect { worker.perform(atts) }.to change { gtag.reload.redeemed? }.from(false).to(true)
  end

  it "propagates alert if gtag is already redeemed" do
    gtag.update(redeemed: true)
    expect(Alert).to receive(:propagate).once
    worker.perform(atts)
  end
end
