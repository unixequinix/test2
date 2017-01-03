require "spec_helper"

RSpec.describe Companies::Api::V1::BalancesController, type: :controller do
  let(:event) { create(:event) }
  let(:company) { create(:company) }
  let(:customer) { create(:customer, event: event) }
  let(:gtag) { create(:gtag, event: event, customer: customer) }

  before do
    create(:company_event_agreement, event: event, company: company)
  end

  describe "GET show" do
    context "when authenticated" do
      before(:each) { http_login(event.token, company.access_token) }

      context "when the gtag belongs to the event" do
        before(:each) { get :show, params: { event_id: event, id: gtag.tag_uid } }

        it "returns a 200 status code" do
          expect(response).to be_ok
        end

        it "returns the balance of the Gtag" do
          body = JSON.parse(response.body)
          expect(body["tag_uid"]).to eq(gtag.tag_uid)
          expect(body["balance"]).to eq(gtag.customer.credits)
          expect(body["currency"]).to eq(gtag.event.token_symbol)
        end
      end

      context "when the gtag doesn't belong to the event" do
        it "returns a 404 status code" do
          get :show, params: { event_id: event, id: 999 }
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :show, params: { event_id: event, id: gtag.tag_uid }
        expect(response).to be_unauthorized
      end
    end
  end
end
