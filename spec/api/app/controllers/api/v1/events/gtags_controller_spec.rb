require "rails_helper"

RSpec.describe Api::V1::Events::GtagsController, type: :controller do
  let(:event) { Event.last || create(:event) }
  let(:admin) { Admin.first || create(:admin) }

  before do
    create_list(:gtag, 2, event: event)
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      it "has a 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 200
      end

      context "when the If-Modified-Since header is sent" do
        before do
          @new_gtag = create(:gtag, :with_purchaser, event: event)
          @new_gtag.update!(updated_at: Time.now + 4.hours)

          request.headers["If-Modified-Since"] = (@new_gtag.updated_at - 2.hours)
        end

        it "returns only the modified gtags" do
          get :index, event_id: event.id
          gtags = JSON.parse(response.body).map { |m| m["tag_uid"] }
          expect(gtags).to include(@new_gtag.tag_uid)
        end
      end

      context "when the If-Modified-Since header isn't sent" do
        before do
          create(:gtag, :with_purchaser, event: event)
        end

        it "returns the cached gtags" do
          get :index, event_id: event.id
          gtags = JSON.parse(response.body).map { |m| m["tag_uid"] }
          cache_g = JSON.parse(Rails.cache.fetch("v1/event/#{event.id}/gtags")).map do |m|
            m["tag_uid"]
          end

          create(:gtag, :with_purchaser, event: event)
          event_gtags = event.gtags.map(&:tag_uid)

          expect(gtags).to eq(cache_g)
          expect(gtags).not_to eq(event_gtags)
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
        http_login(admin.email, admin.access_token)
        get :show, event_id: event.id, id: Gtag.last.id
      end

      it "has a 200 status code" do
        expect(response.status).to eq 200
      end

      it "returns the gtag specified" do
        body = JSON.parse(response.body)
        expect(body["tag_uid"]).to eq(Gtag.last.tag_uid)
      end
    end

    context "without authentication" do
      it "has a 401 status code" do
        get :show, event_id: event.id, id: Gtag.last.id
        expect(response.status).to eq 401
      end
    end
  end
end
