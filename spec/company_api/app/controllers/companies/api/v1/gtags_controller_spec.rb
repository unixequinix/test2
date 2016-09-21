require "rails_helper"

RSpec.describe Companies::Api::V1::GtagsController, type: :controller do
  let(:event) { create(:event) }
  let(:ticket_type) { create(:company_ticket_type, event: event) }
  let(:company) { ticket_type.company_event_agreement.company }
  let(:gtags) { create_list(:gtag, 2, :with_purchaser, event: event) }

  describe "GET index" do
    context "when authenticated" do
      before do
        gtags
        http_login(event.token, company.access_token)
        get :index, event_id: event
      end

      pending "returns 200 status code" do
        expect(response.status).to eq(200)
      end

      pending "returns only the tickets for that company" do
        ws_gtags = JSON.parse(response.body)["gtags"].map { |m| m["tag_uid"] }
        expect(gtags.map(&:tag_uid)).to match_array(ws_gtags)
      end
    end

    context "when not authenticated" do
      pending "returns a 401 status code" do
        get :index, event_id: event
        expect(response.status).to eq(401)
      end
    end
  end

  describe "GET show" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the ticket belongs to the company" do
        before { get :show, event_id: event, id: gtags.last }

        pending "returns a 200 status code" do
          expect(response.status).to eq(200)
        end

        pending "returns the correct gtag" do
          body = JSON.parse(response.body)
          expect(body["tag_uid"]).to eq(gtags.last.tag_uid)
          expect(body["purchaser_email"]).to eq(gtags.last.purchaser.email)
        end
      end

      context "when the ticket doesn't belong to the company" do
        pending "returns a 404 status code" do
          get :show, event_id: event, id: "InvalidID"
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      pending "returns a 401 status code" do
        get :show, event_id: event, id: gtags.last.id
        expect(response.status).to eq(401)
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        before do
          @params = {
            tag_uid: "t4gu1d",
            ticket_type_id: ticket_type.id,
            purchaser_attributes: { first_name: "Glownet", last_name: "Glownet", email: "hi@glownet.com" }
          }
        end

        pending "increases the tickets in the database by 1" do
          expect do
            post :create, gtag: @params
          end.to change(Gtag, :count).by(1)
        end

        pending "returns a 201 status code" do
          post :create, gtag: @params
          expect(response.status).to eq(201)
        end

        pending "returns the created ticket" do
          post :create, gtag: @params

          body = JSON.parse(response.body)
          expect(body["tag_uid"]).to eq(Gtag.last.tag_uid)
          expect(body["purchaser_email"]).to eq(Gtag.last.purchaser.email)
        end
      end

      context "when the request is invalid" do
        pending "returns a 422 status code" do
          post :create, gtag: { with: "Invalid request" }
          expect(response.status).to eq(422)
        end
      end
    end

    context "when not authenticated" do
      pending "returns a 401 status code" do
        post :create, ticket: { with: "Some data" }
        expect(response.status).to eq(401)
      end
    end
  end

  describe "PATCH update" do
    let(:gtag) { gtags.first }

    context "when authenticated" do
      before { http_login(event.token, company.access_token) }

      context "when the request is valid" do
        let(:params) { { tag_uid: "n3wtagU1d", purchaser_attributes: { email: "updated@email.com" } } }

        pending "changes ticket's attributes" do
          put :update, id: gtag, gtag: params
          gtag.reload

          expect(gtag.tag_uid).to eq("n3wtagU1d".upcase)
          expect(gtag.purchaser.email).to eq("updated@email.com")
        end

        pending "returns a 200 code status" do
          put :update, id: gtag, gtag: params
          expect(response.status).to eq(200)
        end

        pending "returns the updated ticket" do
          put :update, id: gtag, gtag: params
          body = JSON.parse(response.body)
          gtag.reload
          expect(body["tag_uid"]).to eq(gtag.tag_uid)
        end
      end

      context "when the request is invalid" do
        let(:params) { { tag_uid: nil, purchaser_attributes: { email: "updated@email.com" } } }

        pending "returns a 422 status code" do
          put :update, id: gtag, gtag: params
          expect(response.status).to eq(422)
        end

        pending "doesn't change gtags's attributes" do
          put :update, id: gtag, gtag: params
          gtag.reload
          expect(gtag.tag_uid).to eq(gtag.tag_uid)
        end
      end
    end

    context "when not authenticated" do
      pending "returns a 401 status code" do
        put :update, id: gtag, gtags: { without: "Authenticate" }
        expect(response.status).to eq(401)
      end
    end
  end
end
