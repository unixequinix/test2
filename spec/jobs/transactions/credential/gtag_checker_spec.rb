require "rails_helper"

RSpec.describe Transactions::Credential::GtagChecker, type: :job do
  let(:event) { create(:event) }
  let(:gtag) { create(:gtag, tag_uid: "UID1AT20160321130133", event: event) }
  let(:customer) { create(:customer, event: event) }
  let(:worker) { Transactions::Credential::GtagChecker.new }
  let(:atts) { { gtag_id: gtag.id, customer_id: customer.id } }

  describe "actions include" do
    it "gtag_checkin" do
      expect(worker.class::TRIGGERS).to include("gtag_checkin")
    end
  end
end
