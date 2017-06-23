require "spec_helper"

RSpec.describe Api::V1::Events::TransactionsController, type: :controller do
  include ControllerMacros

  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user) }
  let(:transaction) { CreditTransaction.new }
  let(:params) do
    [
      {
        event_id: "1",
        customer_tag_uid: "324",
        type: "credit",
        transaction_origin: Transaction::ORIGINS[:device],
        action: "test_type",
        operator_tag_uid: "A54DSF8SD3JS0",
        station_id: "34",
        device_uid: "2353",
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
        app_version: "5.7.0"
      }
    ]
  end

  before { http_login(user.email, user.access_token) }

  describe "POST create" do
    context "when the request is VALID" do
      it "returns a 201 status code" do
        allow(Transactions::Base).to receive(:perform_later).and_return(transaction)
        post :create, params: { event_id: event.id, _json: params }
        expect(response.status).to eq(201)
      end

      it "sends all JSON parameters to the base writer" do
        expect(Transactions::Base).to receive(:perform_later).once.with(params.first).and_return(transaction)
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

      context "when there are no parameters" do
        it "returns a 400 status code" do
          event.update!(state: "closed")
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
