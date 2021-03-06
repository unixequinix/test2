require "rails_helper"

RSpec.describe Api::V1::Events::TransactionsController, type: %i[controller api] do
  let(:event) { create(:event, open_devices_api: true, state: "launched") }
  let(:transaction) { CreditTransaction.new }
  let(:params) do
    [
      {
        event_id: "1",
        customer_tag_uid: "324",
        type: "CreditTransaction",
        transaction_origin: "onsite",
        action: "test_type",
        operator_tag_uid: "A54DSF8SD3JS0",
        station_id: "34",
        device_id: "2353",
        device_db_index: "2353",
        device_created_at: "2016-02-05 11:13:39 +0100",
        customer_id: "23",
        status_code: "1",
        status_message: "Ticket already check-in 0034854TYS9QSD4992",
        credits: "2",
        refundable_credits: "2",
        credit_value: "1",
        final_balance: "4",
        final_refundable_balance: "4",
        app_version: "5.7.0",
        payments: [{}].to_json
      }
    ]
  end
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, role: "glowball") }
  let(:device) { create(:device, team: team) }
  let(:device_token) { "#{device.app_id}+++#{device.serial}+++#{device.mac}+++#{device.imei}" }

  before do
    user.event_registrations.create!(user: user, event: event)
    request.headers["HTTP_DEVICE_TOKEN"] = Base64.encode64(device_token)
    http_login(user.email, user.access_token)
  end

  describe "POST create" do
    context "when the request is VALID" do
      it "returns a 201 status code" do
        allow(Transactions::Base).to receive(:perform_later).and_return(transaction)
        post :create, params: { event_id: event.id, _json: params }
        expect(response.status).to eq(201)
      end

      it "sends all JSON parameters to the base writer" do
        expect(Transactions::Base).to receive(:perform_later).once.with(params.first, event.credit.id, event.virtual_credit.id).and_return(transaction)
        post :create, params: { event_id: event.id, _json: params }
      end
    end

    context "when the request is INVALID" do
      context "when there are no parameters" do
        it "returns a 400 status code" do
          post :create, params: { event_id: event.id }
          expect(response.status).to eq(400)
        end
      end

      context "when required parameters are missing" do
        it "returns a 400 status code" do
          params.first.delete(:event_id)
          params.first.delete(:station_id)
          params.first.delete(:action)
          params.first.delete(:customer_id)
          post :create, params: { event_id: event.id, _json: params }
          expect(response.status).to eq(422)
        end
      end
    end
  end
end
