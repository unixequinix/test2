require "rails_helper"

RSpec.describe Api::V1::Events::GtagsController, :type => :controller do
  before do
    @event = create :event
    10.times do
      create(:gtag, event: @event)
    end
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login
      end

      context "if gtag doesn't exist" do
        it "has a 404 status code" do
          get :show, event_id: @event.id, id: 999
          expect(response.status).to eq 404
        end
      end

      context "if gtag exists" do
        it "has a 200 status code" do
          get :index, event_id: Event.last.id

          expect(response.status).to eq 200
        end

        it "returns all the gtags" do
          get :index, event_id: @event.id

          body = JSON.parse(response.body)
          gtags = body.map { |m| m["tag_uid"] }

          expect(gtags).to match_array(Gtag.all.map(&:tag_uid))
        end
      end
    end
    
    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: Event.last.id

        expect(response.status).to eq 401
      end
    end
  end

  describe "GET show" do
    context "with authentication" do
      before(:each) do
        http_login
        get :show, event_id: @event.id, id: Gtag.last.id
      end

      it "has a 200 status code" do
        expect(response.status).to eq 200
      end

      it "returns the gtag specified" do
        body = JSON.parse(response.body)
        expect(body["tag_uid"]).to eq(Gtag.last.tag_uid)
      end

      it "returns the customer_event_profile if it exists"
    end

    context "without authentication" do
      it "has a 401 status code" do
        get :show, event_id: @event.id, id: Gtag.last.id
        expect(response.status).to eq 401
      end
    end
  end
end
