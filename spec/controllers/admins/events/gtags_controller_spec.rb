require 'rails_helper'

RSpec.describe Admins::Events::GtagsController, type: :controller do
  let(:user) { create(:user, role: 'glowball') }
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event, anonymous: false) }
  let(:gtag) { create(:gtag, event: event, customer: customer, active: true) }

  before(:each) { sign_in user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: gtag.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { event_id: event.id, id: gtag.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #merge" do
    before do
      @gtag = create(:gtag, event: event)
      @ticket = create(:ticket, event: event)
      @anon_customer = create(:customer, event: event, anonymous: true)
    end
    it "successfully merged with a gtag" do
      get :merge, params: { event_id: event.id, id: gtag.id, adm_id: @gtag.id, adm_class: @gtag.class.to_s.humanize.downcase }
      expect(flash[:notice]).to be_present
    end
    it "successfully merged with a ticket" do
      get :merge, params: { event_id: event.id, id: gtag.id, adm_id: @ticket.id, adm_class: @ticket.class.to_s.humanize.downcase }
      expect(flash[:notice]).to be_present
    end
    it "successfully merged with an anonymous customer" do
      get :merge, params: { event_id: event.id, id: gtag.id, adm_id: @anon_customer.id, adm_class: @anon_customer.class.to_s.humanize.downcase }
      expect(flash[:notice]).to be_present
    end
  end
end
