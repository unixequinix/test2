require "rails_helper"

RSpec.describe Pokes::BalanceUpdater, type: :job do
  let(:worker) { Pokes::BalanceUpdater.new }
  let(:event) { create(:event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:transaction) { create(:credit_transaction, gtag: gtag, event: event, customer_tag_uid: gtag.tag_uid) }

  it "calls recalculate_balance on the given gtag" do
    allow(CreditTransaction).to receive(:find).with(transaction.id).and_return(transaction)
    allow(transaction).to receive(:gtag).and_return(gtag)
    expect(gtag).to receive(:recalculate_balance).once
    worker.perform(transaction)
  end

  it "creates an alert when customer and operator tag_uids are the same" do
    transaction.update!(operator_tag_uid: gtag.tag_uid)

    expect(Alert).to receive(:propagate).with(event, transaction, "has the same operator and customer UIDs", :medium).once
    worker.perform(transaction)
  end

  it "does not create an alert when customer and operator tag_uids are different" do
    transaction.update!(operator_tag_uid: "NOTTHESAME")

    expect(Alert).not_to receive(:propagate)
    worker.perform(transaction)
  end
end