require 'rails_helper'

RSpec.describe Admins::Events::ReportsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:stat) { create(:stat, event: event) }

  # gate_close_money_recon ---------------------------------------------------------------------------------------------
  describe "GET #gate_close_money_recon" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :gate_close_money_recon, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :gate_close_money_recon, params: { event_id: event.id }
          expect do
            Pundit.authorize(user, stat, :gate_close_money_recon?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :gate_close_money_recon, params: { event_id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
  describe "GET #operator" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :operators, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # gate_close_billing -------------------------------------------------------------------------------------------------
  describe "GET #gate_close_billing" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :gate_close_billing, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :gate_close_billing, params: { event_id: event.id }
          expect do
            Pundit.authorize(user, stat, :gate_close_billing?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :gate_close_billing, params: { event_id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  # cashless -----------------------------------------------------------------------------------------------------------
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
            Pundit.authorize(user, stat, :cashless?)
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

  # products_sale ------------------------------------------------------------------------------------------------------
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
            Pundit.authorize(user, stat, :products_sale?)
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

  # operator -----------------------------------------------------------------------------------------------------------
  describe "GET #operators" do
    context "user is not logged in" do
      it "Should take the user to the Login Page" do
        get :operators, params: { event_id: event.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "user is logged in" do
      before(:each) do
        sign_in user
      end

      context "user is not glowball role" do
        it "should return forbidden response and take me to Event List" do
          get :operators, params: { event_id: event.id }
          expect do
            Pundit.authorize(user, stat, :operators?)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "user is glowball role" do
        it "should return ok response and show reports" do
          user.glowball!
          get :operators, params: { event_id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  # gates --------------------------------------------------------------------------------------------------------------
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
            Pundit.authorize(user, stat, :gates?)
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
end
