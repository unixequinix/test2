require "rails_helper"

RSpec.describe Api::V1::Events::TransactionsController, type: :controller do
  let(:params) {
    { event_id: 1,
      customer_tag_uid: 324,
      transaction_category: "credential",
      transaction_type: "ticket_checkin",
      operator_tag_uid: "A54DSF8SD3JS0",
      station_id: 34,
      device_id: 23,
      device_uid: 2353,
      device_created_at: "2016-02-05 11:13:39 +0100",
      ticket_code: "0034854TYS9QSD4992",
      customer_event_profile_id: 23,
      status_code: 1,
      status_message: "Ticket already check-in 0034854TYS9QSD4992" }
  }

  before do
    @event = create :event
  end

  describe "POST create" do
    it "should send the category" do
    end
    it "should send the attributes"
    it "shouldn't have the category in the attributes"

    context "when the request is VALID" do
      it "should return a 201 status code"
    end

    context "when the request is INVALID" do
      it "should return a 400 status code"
    end
  end
end
