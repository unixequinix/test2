require 'rails_helper'

RSpec.describe Admins::Events::StationsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:station) { create(:station, event: event) }
  let(:poke) { create(:poke, event: event) }

  context "user is logged in" do
    before(:each) { sign_in user }
    describe "GET #index" do
      it "returns a success response" do
        get :index, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET #show" do
      it "returns a success response" do
        get :show, params: { event_id: event.id, id: station.id }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET #new" do
      it "returns a success response" do
        get :new, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET #edit" do
      it "returns a success response" do
        get :edit, params: { event_id: event.id, id: station.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET #_reports" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :reports, params: { event_id: event.id, station_id: station.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :reports, params: { event_id: event.id, station_id: station.id }
          expect do
            Pundit.authorize(user, poke, :reports?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :reports, params: { event_id: event.id, station_id: station.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
