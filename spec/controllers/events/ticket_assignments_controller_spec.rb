require 'spec_helper'
require 'rails-controller-testing'

RSpec.describe Events::TicketAssignmentsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe 'render templates' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET new' do
        get :new, params: { event_id: event }
        expect(response).to be_ok
        expect(response).to render_template('new')
      end
    end

    context 'customer is not logged in' do
      it 'GET new' do
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:event_login)
      end
    end
  end
end
