require 'rails_helper'

RSpec.describe Admins::Events::EventInvitationsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:event_invitation) { create(:event_invitation, event: event) }

  before(:each) { sign_in user }

  describe "post #create" do
    it "is able to create invitations" do
      expect do
        post :create, params: { event_id: event, event_invitation: { email: 'foo@bar.es', event_id: event.id, role: :support } }
      end.to change(EventInvitation, :count).by(1)
    end
  end

  describe "get #resend" do
    it "returns a success response" do
      get :resend, params: { event_id: event, id: event_invitation.id }
      expect(response).to have_http_status(:found)
    end
  end
end
