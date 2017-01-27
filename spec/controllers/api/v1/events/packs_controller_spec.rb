require "spec_helper"

RSpec.describe Api::V1::Events::PacksController, type: :controller do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  let(:db_packs) { event.packs }

  before do
    create(:full_pack, event: event)
    @new_pack = create(:full_pack, event: event, updated_at: Time.zone.now + 4.hours)
  end

  describe "GET index" do
    context "when authenticated" do
      before { http_login(user.email, user.access_token) }

      it "returns a 200 status code" do
        get :index, params: { event_id: event.id }
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, params: { event_id: event.id }
        pack_keys = %w(id name accesses credits user_flags)
        JSON.parse(response.body).map { |pack| expect(pack.keys).to eq(pack_keys) }
      end

      context "with the 'If-Modified-Since' header" do
        it "returns only the modified packs" do
          request.headers["If-Modified-Since"] = (@new_pack.updated_at - 2.hours)
          get :index, params: { event_id: event.id }
          packs = JSON.parse(response.body).map { |m| m["id"] }
          expect(packs).to eq([@new_pack.id])
        end
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the packs" do
          get :index, params: { event_id: event.id }
          api_packs = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_packs).to eq(db_packs.map(&:id))
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
