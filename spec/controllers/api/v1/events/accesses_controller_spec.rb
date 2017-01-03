require "spec_helper"

RSpec.describe Api::V1::Events::AccessesController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:db_accesses) { event.accesses }

  before do
    create(:access, event: event)
    @new_access = create(:access, event: event, updated_at: Time.zone.now + 4.hours)
  end

  describe "GET index" do
    context "when authenticated" do
      before { http_login(admin.email, admin.access_token) }

      it "returns a 200 status code" do
        get :index, params: { event_id: event.id }
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, params: { event_id: event.id }
        access_keys = %w(id name mode position memory_length)
        JSON.parse(response.body).map { |access| expect(access.keys).to eq(access_keys) }
      end

      context "with the 'If-Modified-Since' header" do
        it "returns only the modified accesses" do
          request.headers["If-Modified-Since"] = (@new_access.updated_at - 2.hours)
          get :index, params: { event_id: event.id }
          accesses = JSON.parse(response.body).map { |m| m["id"] }
          expect(accesses).to eq([@new_access.id])
        end
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the accesses" do
          get :index, params: { event_id: event.id }
          api_accesses = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_accesses).to eq(db_accesses.map(&:id))
        end
      end
    end

    context "when unauthenticated" do
      it "returns a 401 status code" do
        get :index, params: { event_id: event.id }
        expect(response).to be_unauthorized
      end
    end
  end
end
