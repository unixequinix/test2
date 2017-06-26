require "spec_helper"

RSpec.describe Admins::EventSeriesController, type: :controller do
  let(:user) { create(:user) }

  # GET index
  describe "GET index" do
    before do
      create(:event_serie, :with_events)
      sign_in user
    end

    context "when authenticated with not admin role" do
      it "redirect if user is not admin role" do
        get :index
        expect(response).to redirect_to(admins_events_path)
      end
    end

    context "when authenticated with admin role" do
      before do
        subject.current_user.role = 'admin'
        subject.current_user.save
      end

      it "render index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "assigns event series" do
        get :index
        expect(assigns(:event_series)).to eq(EventSerie.all)
      end
    end
  end

  # GET show
  describe "GET show" do
    before do
      @event_serie = create(:event_serie, :with_events)
      sign_in user
    end

    context "when authenticated with not admin role" do
      it "redirect if user is not admin role" do
        get :show, params: { id: @event_serie.id }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    context "when authenticated with admin role" do
      before do
        subject.current_user.role = 'admin'
        subject.current_user.save
      end

      it "assigns event series" do
        get :show, params: { id: @event_serie.id }
        expect(assigns(:event_serie)).to eq(@event_serie)
      end

      it "render new template" do
        get :show, params: { id: @event_serie.id }
        expect(response).to render_template(:show)
      end
    end
  end

  # GET new
  describe "GET new" do
    before do
      sign_in user
    end

    context "when authenticated with not admin role" do
      it "redirect if user is not admin role" do
        get :new
        expect(response).to redirect_to(admins_events_path)
      end
    end

    context "when authenticated with admin role" do
      before do
        subject.current_user.role = 'admin'
        subject.current_user.save
      end

      it "should be a new record" do
        get :new
        expect(assigns(:event_serie)).to be_a_new(EventSerie)
      end

      it "render new template" do
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  # POST create
  describe "POST create" do
    before do
      sign_in user
    end

    context "when authenticated with not admin role" do
      it "redirect if user is not admin role" do
        post :create, params: { event_serie: { name: "New Event Serie" } }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    context "when authenticated with admin role" do
      before do
        subject.current_user.role = 'admin'
        subject.current_user.save
      end

      it "increases the event serie in the database by 1" do
        expect do
          post :create, params: { event_serie: { name: "New Event Serie" } }
        end.to change(EventSerie, :count).by(1)
      end

      it "redirect to detail if success" do
        post :create, params: { event_serie: { name: "New Event Serie" } }
        expect(response).to redirect_to(response.location)
      end

      it "render new template on error" do
        post :create, params: { event_serie: { name: nil } }
        expect(response).to render_template(:new)
      end
    end
  end

  # PUT update
  describe "PUT update" do
    before do
      @event_serie = create(:event_serie, :with_events)
      sign_in user
    end

    context "when authenticated with not admin role" do
      it "redirect if user is not admin role" do
        put :update, params: { id: @event_serie.id }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    context "when authenticated with admin role" do
      before do
        subject.current_user.role = 'admin'
        subject.current_user.save
      end

      it "assigns event series" do
        put :update, params: { id: @event_serie.id, event_serie: { name: "Updated Event Serie" } }
        @event_serie.reload
        expect(@event_serie.name).to eq("Updated Event Serie")
      end

      it "render show template" do
        put :update, params: { id: @event_serie.id, event_serie: { name: "Updated Event Serie" } }
        @event_serie.reload
        expect(response).to redirect_to(response.location)
      end

      it "render edit template on error" do
        put :update, params: { id: @event_serie.id, event_serie: { name: "" } }
        @event_serie.reload
        expect(response).to render_template(:edit)
      end
    end
  end

  # DELETE destroy
  describe "DELETE destroy" do
    before do
      @event_serie = create(:event_serie, :with_events)
      sign_in user
    end

    context "when authenticated with not admin role" do
      it "redirect if user is not admin role" do
        delete :destroy, params: { id: @event_serie.id }
        expect(response).to redirect_to(admins_events_path)
      end
    end

    context "when authenticated with admin role" do
      before do
        subject.current_user.role = 'admin'
        subject.current_user.save
      end

      it "decreases the event serie in the database by 1" do
        expect do
          delete :destroy, params: { id: @event_serie.id }
        end.to change(EventSerie, :count).by(-1)
      end
    end
  end
end
