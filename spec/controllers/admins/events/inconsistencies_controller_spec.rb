require 'rails_helper'

RSpec.describe Admins::Events::InconsistenciesController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }

  before(:each) { sign_in user }

  describe "GET #missing" do
    it "returns a success response" do
      get :missing, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #real" do
    it "returns a success response" do
      get :real, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #resolvable" do
    it "returns a success response" do
      get :resolvable, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
