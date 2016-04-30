require "rails_helper"

RSpec.describe Api::V1::Events::BannedGtagsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:event) { create(:event) }

  describe "GET index" do
    context "with authentication" do
      before(:each) { http_login(admin.email, admin.access_token) }

      it "has a 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 200
      end

      it "returns all the banned gtags" do
        gtags = create_list(:gtag, 2, banned: true, event: event)
        get :index, event_id: event.id
        body = JSON.parse(response.body)
        ws_gtags = body.map { |m| m["tag_uid"] }
        gtags.each { |gtag|  expect(ws_gtags).to include(gtag.tag_uid) }
      end
    end

    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 401
      end
    end
  end
end
