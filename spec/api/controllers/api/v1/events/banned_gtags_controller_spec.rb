require "rails_helper"

RSpec.describe Api::V1::Events::BannedGtagsController, :type => :controller do
  describe "GET index" do
    before do
      create(:event, :with_banned_gtags)
    end

    context "with authentication" do
      before(:each) do
        http_login
      end

      it "has a 200 status code" do
        get :index, :event_id => Event.last.id

        expect(response.status).to eq 200
      end

      it "returns all the banned gtags" do
        get :index, :event_id => Event.last.id

        body = JSON.parse(response.body)
        banned_tags = body.map { |m| m["tag_uid"] }

        expect(banned_tags).to match_array(Gtag.all.map(&:tag_uid))
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index, :event_id => Event.last.id

        expect(response.status).to eq 401
      end
    end
  end
end
