require "rails_helper"

RSpec.describe Companies::Api::V1::BalancesController, type: :controller do
  let(:event) { create(:event) }
  let(:company) { create(:company) }
  let(:profile) { create(:profile, event: event) }
  let(:gtag) { create(:gtag, event: event, profile: profile) }

  before do
    create(:company_event_agreement, event: event, company: company)
  end

  describe "GET show" do
    context "when authenticated" do
      before(:each) { http_login(event.token, company.access_token) }

      context "when the gtag belongs to the event" do
        before(:each) { get :show, event_id: event, id: gtag.tag_uid }

        it "returns a 200 status code" do
          expect(response.status).to eq(200)
        end

        it "returns the balance of the Gtag" do
          body = JSON.parse(response.body)
          expect(body["tag_uid"]).to eq(gtag.tag_uid)
          expect(body["balance"]).to eq(gtag.profile.credits.to_s)
          expect(body["currency"]).to eq(gtag.event.token_symbol)
        end
      end

      context "when the gtag doesn't belong to the event" do
        it "returns a 404 status code" do
          get :show, event_id: event, id: 999
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :show, event_id: event, id: gtag.tag_uid
        expect(response.status).to eq(401)
      end
    end
  end
end