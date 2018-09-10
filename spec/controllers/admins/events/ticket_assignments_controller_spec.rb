require 'rails_helper'

RSpec.describe Admins::Events::TicketAssignmentsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  before(:each) { sign_in user }

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { event_id: event.id, id: customer.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
