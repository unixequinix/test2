require "rails_helper"

RSpec.describe Companies::Api::V1::BannedGtagsController, type: :controller do
  before(:all) do
    @event = create(:event)
    @company = create(:company)
    @agreement = create(:company_event_agreement, event: @event, company: @company)
    @ticket_type = create(:company_ticket_type, event: @event, company_event_agreement: @agreement)

    create_list(:gtag, 2, :banned, event: @event, company_ticket_type: @ticket_type)
  end

  describe "GET index" do
    context "when authenticated" do
      before(:each) do
        http_login(@event.token, @company.access_token)
      end

      it "returns 200 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(200)
      end

      it "returns only the banned gtags for that company" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)
        gtags = body["blacklisted_gtags"].map { |m| m["tag_uid"] }

        db_gtags = Gtag.banned
                   .joins(company_ticket_type: :company_event_agreement)
                   .where(event: @event, company_event_agreements: { id: @agreement.id })

        expect(gtags).to match_array(db_gtags.map(&:tag_uid))
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(401)
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before(:each) do
        http_login(@event.token, @company.access_token)
      end

      context "when the request is valid" do
        before(:each) do
          @gtag = create(:gtag, :with_purchaser, event: @event, company_ticket_type: @ticket_type)
        end

        it "increases the banned gtags in the database by 1" do
          expect do
            post :create, gtags_blacklist: { tag_uid: @gtag.tag_uid }
          end.to change(BannedGtag, :count).by(1)
        end

        it "returns a 201 status code" do
          post :create, gtags_blacklist: { tag_uid: @gtag.tag_uid }
          expect(response.status).to eq(201)
        end

        it "returns the banned gtag" do
          post :create, gtags_blacklist: { tag_uid: @gtag.tag_uid }

          body = JSON.parse(response.body)
          expect(body["tag_uid"]).to eq(Gtag.banned.last.tag_uid)
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
    before(:each) do
      @gtag = create(:gtag,
                     :banned,
                     tag_uid: "Glownet",
                     event: @event,
                     company_ticket_type: @ticket_type)
    end

    context "when authenticated" do
      before(:each) do
        http_login(@event.token, @company.access_token)
      end

      context "when the request is valid" do
        it "removes the ticket from the banned table" do
          delete :destroy, id: @gtag.tag_uid
          expect(Gtag.banned.last.tag_uid).not_to eq("Glownet")
        end

        it "returns a 204 code status" do
          put :destroy, id: @gtag.tag_uid
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
        put :destroy, id: Gtag.banned.last.tag_uid, ticket: { without: "Authenticate" }
        expect(response.status).to eq(401)
      end
    end
  end
end
