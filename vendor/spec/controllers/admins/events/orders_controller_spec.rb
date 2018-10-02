require 'rails_helper'

RSpec.describe Admins::Events::OrdersController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let(:order) { create(:order, event: event, customer: customer) }

  before(:each) { sign_in user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, customer_id: customer.id, id: order.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { event_id: event.id, customer_id: customer.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
