require 'rails_helper'

RSpec.describe Admins::Events::CustomAnalyticsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }

  before(:each) { sign_in user }

  describe "GET #money" do
    it "returns a success response" do
      get :money, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #credits" do
    it "returns a success response" do
      get :credits, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #sales" do
    it "returns a success response" do
      get :sales, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #checkin" do
    it "returns a success response" do
      get :checkin, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #access" do
    it "returns a success response" do
      get :access, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end
end
