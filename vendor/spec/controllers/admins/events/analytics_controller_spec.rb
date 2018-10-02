require 'rails_helper'

RSpec.describe Admins::Events::AnalyticsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }

  before(:each) { sign_in user }

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #cash_flow" do
    it "returns a success response" do
      get :cash_flow, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #cash_flow" do
    it "returns a success response" do
      get :cash_flow, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #partner_reports" do
    it "returns a success response" do
      get :partner_reports, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #sales" do
    it "returns a success response" do
      get :credits_flow, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #checkin" do
    it "returns a success response" do
      get :checkin, params: { event_id: event.id }, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end
end
