require 'rails_helper'

RSpec.describe Admins::Events::ReportsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:poke) { create(:poke, event: event) }

  describe "GET #_money_recon" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :money_recon, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :money_recon, params: { event_id: event.id }
          expect do
            Pundit.authorize(user, poke, :reports?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :money_recon, params: { event_id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "GET #products_sale" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :products_sale, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :cashless, params: { event_id: event.id }
          expect do
            Pundit.authorize(user, poke, :reports?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :products_sale, params: { event_id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "GET #cashless" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :cashless, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :cashless, params: { event_id: event.id }
          expect do
            Pundit.authorize(user, poke, :reports?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :cashless, params: { event_id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "GET #gates" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :gates, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :gates, params: { event_id: event.id }
          expect do
            Pundit.authorize(user, poke, :reports?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :gates, params: { event_id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "GET #activations" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :activations, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :activations, params: { event_id: event.id }
          expect do
            Pundit.authorize(user, poke, :reports_billing?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :activations, params: { event_id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "GET #devices" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :devices, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :devices, params: { event_id: event.id }
          expect do
            Pundit.authorize(user, poke, :reports_billing?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :devices, params: { event_id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
