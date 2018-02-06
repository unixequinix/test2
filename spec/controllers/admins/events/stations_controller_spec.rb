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
end
