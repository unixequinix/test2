require 'rails_helper'

RSpec.describe Admins::Events::StatsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:stat) { create(:stat, event: event) }

  describe "GET #edit" do
    before(:each) do
      sign_in user
    end

    context "user is not glowball role" do
      it "should return forbidden response" do
        expect do
          Pundit.authorize(user, stat, :edit?)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "user is glowball role" do
      before(:each) do
        user.glowball!
      end

      it "should return ok response" do
        get :edit, params: { event_id: event.id, id: stat.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PUT #update" do
    before(:each) do
      sign_in user
    end

    context "user is not glowball role" do
      it "should return forbidden response" do
        expect do
          Pundit.authorize(user, stat, :edit?)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "user is glowball role" do
      before(:each) do
        user.glowball!
      end

      it "should redirect after update current stat" do
        put :update, params: { event_id: event.id, id: stat.id }
        expect(response).to redirect_to(issues_admins_event_stats_path(event, error_type: stat.error_code))
      end

      it "should update current stat" do
        put :update, params: { event_id: event.id, id: stat.id }
        expect(stat.error_code).to be(nil)
      end

      it "should redirect after update all selected stats" do
        stat2 = create(:stat, event: event)

        put :update, params: { event_id: event.id, id: stat.id, ids: [stat.id, stat2.id] }
        expect(response).to redirect_to(issues_admins_event_stats_path(event, error_type: stat.error_code))
      end

      it "should update all selected stats" do
        stat2 = create(:stat, event: event)

        put :update, params: { event_id: event.id, id: stat.id, ids: [stat.id, stat2.id] }
        expect(stat2.error_code && stat.error_code).to be(nil)
      end
    end
  end

  describe "GET #issues" do
    before(:each) do
      sign_in user
    end

    context "user is not glowball role" do
      it "should return forbidden response" do
        expect do
          Pundit.authorize(user, stat, :edit?)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "user is glowball role" do
      before(:each) do
        user.glowball!
      end

      it "should return ok response" do
        get :issues, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
