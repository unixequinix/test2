require 'rails_helper'

RSpec.describe Admins::Events::CompaniesController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:company) { create(:company, event: event) }

  before(:each) { sign_in user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { event_id: event.id, id: company.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { event_id: event.id, id: company.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
