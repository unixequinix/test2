require "rails_helper"

RSpec.describe Api::V1::Events::AccessesController, type: :controller do
  let(:event) { Event.first || create(:event) }
  let(:admin) { Admin.first || create(:admin) }
  let(:db_accesses) do
    Access.joins(:catalog_item).where(catalog_items: { event_id: event.id }).pluck(:id)
  end

  before do
    create(:catalog_item, :with_access, event: event)
    @new_access = create(:catalog_item, :with_access, event: event)
    @new_access.update!(updated_at: Time.now + 4.hours)
    @new_access.catalogable.update!(updated_at: Time.now + 4.hours)
  end

  describe "GET index" do
    context "when authenticated" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      it "returns a 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 200
      end

      context "with the 'If-Modified-Since' header" do
        it "returns only the modified accesses" do
          request.headers["If-Modified-Since"] = (@new_access.updated_at - 2.hours)
          get :index, event_id: event.id
          accesses = JSON.parse(response.body).map { |m| m["id"] }
          expect(accesses).to eq([@new_access.id])
        end
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the accesses" do
          get :index, event_id: event.id
          api_accesses = JSON.parse(response.body).map { |m| m["id"] }
          event_accesses = Access.joins(:catalog_item)
                           .where(catalog_items: { event_id: event.id }).pluck(:id)
          expect(api_accesses).to eq(event_accesses)
        end
      end
    end

    context "when unauthenticated" do
      it "returns a 401 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 401
      end
    end
  end
end
