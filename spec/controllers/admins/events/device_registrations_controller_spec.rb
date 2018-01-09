require 'rails_helper'

RSpec.describe Admins::Events::DeviceRegistrationsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:device_registration) { create(:device_registration, event: event) }

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
end
