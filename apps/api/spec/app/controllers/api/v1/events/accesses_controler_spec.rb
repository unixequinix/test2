require "spec_helper"

RSpec.describe Api::V1::Events::AccessesController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { Admin.first || create(:admin) }
  let(:db_accesses) do
    Access.joins(:catalog_item).where(catalog_items: { event_id: event.id }).pluck(:id)
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
        create(:catalog_item, :with_access, event: event)
      end

      it "has a 200 status code" do
        get :index, event_id: event.id

        expect(response.status).to eq 200
      end

      it "returns all the accesses" do
        get :index, event_id: event.id

        body = JSON.parse(response.body)
        accesses = body.map { |m| m["id"] }

        expect(accesses).to eq(db_accesses)
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
