require 'rails_helper'

RSpec.describe Admins::Events::AccessesController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:access) { create(:access, event: event) }

  before(:each) { sign_in user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: access.id }
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
    it "returns a success response if event is created" do
      event.update! state: "created"
      get :edit, params: { event_id: event.id, id: access.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns a redirect response if event is not created" do
      event.update! state: "launched"
      get :edit, params: { event_id: event.id, id: access.id }
      expect(response).to have_http_status(:found)
    end
  end
end
