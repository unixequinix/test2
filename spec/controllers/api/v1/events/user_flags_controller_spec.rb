require "spec_helper"

RSpec.describe Api::V1::Events::UserFlagsController, type: :controller do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  let(:db_user_flags) { event.user_flags }

  before do
    create(:user_flag, event: event)
    @new_user_flag = create(:user_flag, event: event, updated_at: Time.zone.now + 4.hours)
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
        user_flag_keys = %w(id name)
        JSON.parse(response.body).map { |user_flag| expect(user_flag.keys).to eq(user_flag_keys) }
      end

      context "with the 'If-Modified-Since' header" do
        it "returns only the modified user_flags" do
          request.headers["If-Modified-Since"] = (@new_user_flag.updated_at - 2.hours)
          get :index, params: { event_id: event.id }
          user_flags = JSON.parse(response.body).map { |m| m["id"] }
          expect(user_flags).to eq([@new_user_flag.id])
        end
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the user_flags" do
          get :index, params: { event_id: event.id }
          api_user_flags = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_user_flags).to eq(db_user_flags.map(&:id))
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
