require 'rails_helper'

RSpec.describe Admins::Events::CustomersController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  before(:each) { sign_in user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: customer.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { event_id: event.id, id: customer.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #download_transactions" do
    it "returns a redirect response" do
      get :download_transactions, params: { event_id: event.id, id: customer.id }
      expect(response).to have_http_status(:redirect)
    end
  end
end
