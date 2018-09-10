require "rails_helper"

RSpec.describe Validators::MissingCounter, type: :job do
  let(:worker) { Validators::MissingCounter.new }
  let(:event) { create(:event) }
  let(:gtag)  { create(:gtag, tag_uid: "123456789", event: event) }

  describe "unordered transactions creation" do
    it "should not make invalid gtag if all gtag counters exist" do
      expect { worker.perform(create(:credential_transaction, event: event, gtag: gtag, action: 'ticket_checkin', gtag_counter: 0)) }.not_to change(gtag.reload, :complete)
      expect { worker.perform(create(:access_transaction, event: event, gtag: gtag, action: 'record_access', gtag_counter: 2)) }.to change(gtag.reload, :complete).from(true).to(false)
      expect { worker.perform(create(:order_transaction, event: event, gtag: gtag, action: 'record_purchase', gtag_counter: 1)) }.to change(gtag.reload, :complete).from(false).to(true)
    end
  end
end
