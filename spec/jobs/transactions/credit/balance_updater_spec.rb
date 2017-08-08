require "rails_helper"

RSpec.describe Transactions::Credit::BalanceUpdater, type: :job do
  let(:worker) { Transactions::Credit::BalanceUpdater }
  let(:event) { create(:event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:atts) { { gtag_id: gtag.id, event_id: event.id, customer_tag_uid: gtag.tag_uid } }

  it "calls recalculate_balance on the given gtag" do
    expect(Gtag).to receive(:find).once.with(gtag.id).and_return(gtag)
    expect(gtag).to receive(:recalculate_balance).once
    worker.perform_now(atts)
  end

  it "creates an alert when customer and operator tag_uids are the same" do
    transaction = create(:credit_transaction, event: event, customer_tag_uid: gtag.tag_uid)
    atts[:operator_tag_uid] = gtag.tag_uid
    atts[:transaction_id] = transaction.id

    expect(Alert).to receive(:propagate).with(event, "has the same operator and customer UIDs", :medium, transaction).once
    worker.perform_now(atts)
  end

  it "does not create an alert when customer and operator tag_uids are different" do
    atts[:operator_tag_uid] = "NOTTHESAME"

    expect(Alert).not_to receive(:propagate)
    worker.perform_now(atts)
  end
end
