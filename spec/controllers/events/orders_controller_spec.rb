require 'rails_helper'

RSpec.describe Events::OrdersController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let(:catalog_item) { create(:catalog_item, event: event) }
  let(:station) { create(:station, event: event) }
  let(:order) { create(:order, customer: customer, event: event) }

  describe 'render templates' do
    context 'when customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET new with topups closed' do
        create(:station_catalog_item, catalog_item: catalog_item, station: station)
        event.update open_topups: false
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:customer_root)
      end

      it 'GET new with topups closed' do
        create(:station_catalog_item, catalog_item: catalog_item, station: station)
        event.update open_topups: false
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:customer_root)
      end

      it 'GET new' do
        create(:station_catalog_item, catalog_item: catalog_item, station: station)
        get :new, params: { event_id: event }
        expect(response).to be_ok
      end

      it 'POST create' do
        create(:station_catalog_item, catalog_item: catalog_item, station: station)
        get :new, params: { event_id: event }
        expect(response).to be_ok
      end

      it 'GET show' do
        get :show, params: { event_id: event, id: order }
        expect(response).to be_ok
      end

      it 'GET success' do
        get :success, params: { event_id: event, id: order }
        expect(response).to be_ok
      end

      it 'GET error' do
        get :error, params: { event_id: event, id: order }
        expect(response).to be_ok
      end

      it 'GET abstract_error' do
        get :abstract_error, params: { event_id: event, id: order }
        expect(response).to be_ok
      end
    end

    context 'when customer is not logged in' do
      it 'GET new with topups closed' do
        create(:station_catalog_item, catalog_item: catalog_item, station: station)
        event.update open_topups: false
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:event_login)
      end

      it 'GET new' do
        create(:station_catalog_item, catalog_item: catalog_item, station: station)
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:event_login)
      end

      it 'GET show' do
        get :show, params: { event_id: event, id: order }
        expect(response).to redirect_to(:event_login)
      end

      it 'GET success' do
        get :success, params: { event_id: event, id: order }
        expect(response).to redirect_to(:event_login)
      end

      it 'GET error' do
        get :error, params: { event_id: event, id: order }
        expect(response).to redirect_to(:event_login)
      end

      it 'GET abstract_error' do
        get :abstract_error, params: { event_id: event, id: order }
        expect(response).to redirect_to(:event_login)
      end
    end
  end
end
