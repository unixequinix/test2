require "rails_helper"

RSpec.describe Companies::Api::V1::BannedGtagsController, type: :controller do
  let(:event) { create(:event) }
  let(:company) { create(:company) }
  let(:agreement) { create(:company_event_agreement, event: event, company: company) }
  let(:t_type) { create(:company_ticket_type, event: event, company_event_agreement: agreement) }
  before { create_list(:gtag, 2, banned: true, event: event, company_ticket_type: t_type) }

  describe "GET index" do
    context "when authenticated" do
      before(:each) do
        http_login(event.token, company.access_token)
      end

      it "returns 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq(200)
      end

      it "returns only the banned gtags for that company" do
        get :index, event_id: event.id

        body = JSON.parse(response.body)
        gtags = body["blacklisted_gtags"].map { |m| m["tag_uid"] }

        db_gtags = event.gtags.where(banned: true)
                        .joins(company_ticket_type: :company_event_agreement)
                        .where(company_event_agreements: { id: agreement.id })

        expect(gtags).to match_array(db_gtags.map(&:tag_uid))
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq(401)
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before(:each) do
        http_login(event.token, company.access_token)
      end

      context "when the request is valid" do
        let(:gtag) { create(:gtag, :with_purchaser, event: event, company_ticket_type: t_type) }

        it "increases the banned gtags in the database by 1" do
          post :create, gtags_blacklist: { tag_uid: gtag.tag_uid }
          expect(gtag.reload).to be_banned
        end

        it "returns a 201 status code" do
          post :create, gtags_blacklist: { tag_uid: gtag.tag_uid }
          expect(response.status).to eq(201)
        end

        it "returns the banned gtag" do
          post :create, gtags_blacklist: { tag_uid: gtag.tag_uid }

          body = JSON.parse(response.body)
          expect(body["tag_uid"]).to eq(gtag.tag_uid)
        end
      end

      context "when the request is invalid" do
        it "returns a 400 status code" do
          post :create, gtags_blacklist: { with: "Invalid request" }
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        post :create, gtags_blacklist: { with: "Some data" }
        expect(response.status).to eq(401)
      end
    end
  end

  describe "DELETE destroy" do
    let(:gtag) { create(:gtag, banned: true, event: event, company_ticket_type: t_type) }

    context "when authenticated" do
      before(:each) do
        http_login(event.token, company.access_token)
      end

      context "when the request is valid" do
        it "unbans the ticket" do
          delete :destroy, id: gtag.tag_uid
          expect(gtag.reload).not_to be_banned
        end

        it "returns a 204 code status" do
          put :destroy, id: gtag.tag_uid
          expect(response.status).to eq(204)
        end
      end

      context "when the request is invalid" do
        it "returns a 404 status code" do
          put :destroy, id: "InvalidTicketReference"
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        put :destroy, id: gtag.tag_uid, ticket: { without: "Authenticate" }
        expect(response.status).to eq(401)
      end
    end
  end
end
