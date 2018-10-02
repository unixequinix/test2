require "rails_helper"

RSpec.describe Admins::Events::CreditsController, type: :controller do
  let(:user) { create(:user, role: 'promoter') }
  let(:event) { create(:event, state: 'created') }

  before(:each) do
    create(:event_registration, event: event, user: user)
    sign_in user
  end

  context "event created" do
    describe "GET #new" do
      it "returns a success response" do
        get :new, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST #create" do
      it "redirects to event settings with success" do
        post :create, params: { event_id: event.id, credit: { name: 'Product1', vat: 0.to_f, symbol: 'C' } }
        expect(response).to redirect_to(edit_admins_event_path(event, current_tab: 'credits-panel'))
      end

      it "render new if errors any" do
        post :create, params: { event_id: event.id, credit: { name: nil, vat: 0.to_f } }
        expect(response).to have_http_status(200)
      end
    end

    describe "GET #edit" do
      it "redirects to event settings with success" do
        get :create, params: { event_id: event.id, id: event.credit, credit: { name: 'Product1', vat: 0.to_f, symbol: 'C' } }
        expect(response).to redirect_to(edit_admins_event_path(event, current_tab: 'credits-panel'))
      end

      it "render new if errors any" do
        get :create, params: { event_id: event.id, credit: { name: nil, vat: 0.to_f } }
        expect(response).to have_http_status(200)
      end
    end

    describe "PUT #update" do
      it "redirects to event settings with success" do
        put :update, params: { event_id: event.id, id: event.credit, credit: { name: 'Product2', vat: 0.to_f, symbol: 'TK' } }
        expect(response).to redirect_to(edit_admins_event_path(event, current_tab: 'credits-panel'))
      end

      it "render new if errors any" do
        put :update, params: { event_id: event.id, id: event.credit, credit: { name: nil, vat: 0.to_f } }
        expect(response).to have_http_status(200)
      end
    end

    describe "DELETE #destroy" do
      it "redirects to event settings with success" do
        delete :destroy, params: { event_id: event.id, id: event.credit.id }
        expect(response).to redirect_to(edit_admins_event_path(event, current_tab: 'credits-panel'))
      end
    end

    describe "PUT #sort" do
      it "redirect to events index" do
        put :sort, params: { event_id: event.id, order: { "0" => { "id" => event.virtual_credit.id.to_s }, "1" => { "id" => event.credit.id.to_s } } }
        expect(response).to have_http_status(200)
      end
    end
  end

  context "event launched" do
    before(:each) { event.update(state: 'launched') }

    describe "GET #new" do
      it "redirect to events index" do
        get :new, params: { event_id: event.id }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    describe "POST #create" do
      it "redirect to events index" do
        post :create, params: { event_id: event.id, credit: { name: 'Product1', vat: 0.to_f, symbol: 'C' } }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    describe "GET #edit" do
      it "redirect to events index" do
        get :create, params: { event_id: event.id, id: event.credit, credit: { name: 'Product1', vat: 0.to_f, symbol: 'C' } }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    describe "PUT #update" do
      it "redirect to events index" do
        put :update, params: { event_id: event.id, id: event.credit, credit: { name: 'Product2', vat: 0.to_f, symbol: 'TK' } }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    describe "DELETE #destroy" do
      it "redirect to events index" do
        delete :destroy, params: { event_id: event.id, id: event.credit.id }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    describe "DELETE #destroy" do
      it "redirect to events index" do
        delete :destroy, params: { event_id: event.id, id: event.credit.id }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    describe "PUT #sort" do
      it "redirect to events index" do
        put :sort, params: { event_id: event.id, order: { "0" => { "id" => event.virtual_credit.id.to_s }, "1" => { "id" => event.credit.id.to_s } } }
        expect(response).to redirect_to(admins_events_path)
      end
    end
  end
end
