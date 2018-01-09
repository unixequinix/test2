require 'rails_helper'

RSpec.describe Admins::Events::DeviceRegistrationsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:team) { create(:team, leader: user) }
  let(:device_registration) { create(:device_registration, event: event) }
  let(:valid_device_attributes) { { device_ids: [create(:device).id], initialization_type: nil } }

  describe "GET #index" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        get :index, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      it "returns a success response" do
        get :index, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET #show" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        get :show, params: { event_id: event.id, id: device_registration.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      it "returns a success response" do
        get :show, params: { event_id: event.id, id: device_registration.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET #new" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        get :new, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      it "returns a success response" do
        get :new, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST #create" do
    context "user is not logged in" do
      it "redirects to sign_in path" do
        post :create, params: { event_id: event.id, device_registration: valid_device_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before do
        sign_in(user)
      end

      it "redirects to new device registration path" do
        post :create, params: { event_id: event.id, device_registration: valid_device_attributes }
        expect(response).to redirect_to(new_admins_event_device_registration_path(event))
      end

      it "changes device registration count" do
        post :create, params: { event_id: event.id, device_registration: valid_device_attributes }
      end

      it "should have default intilization type" do
        post :create, params: { event_id: event.id, device_registration: valid_device_attributes }
        expect(DeviceRegistration.last.initialization_type).to eq('FULL_INITIALIZATION')
      end
    end
  end
end
