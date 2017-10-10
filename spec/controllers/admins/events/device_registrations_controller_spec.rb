require 'rails_helper'

RSpec.describe Admins::Events::DeviceRegistrationsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:device_registration) { create(:device_registration) }

  before(:each) { sign_in user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: GET #show GET #transactions
end
