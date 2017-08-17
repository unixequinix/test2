require 'rails_helper'

RSpec.describe Events::GtagAssignmentsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe 'render templates' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET new' do
        get :new, params: { event_id: event }
        expect(response).to be_ok
      end

      context "gtag initialization without customer assignation" do
        before { @gtag = create(:gtag, event: event) }

        it 'POST create' do
          expect do
            post :create, params: { event_id: event, gtag: { reference: @gtag.tag_uid } }
          end.to change(Gtag, :count).by(0)
        end

        it 'POST initialize gtag with anonymous customer' do
          post :create, params: { event_id: event, gtag: { reference: @gtag.tag_uid } }
          expect(event.gtags.last.customer.anonymous).to be(true)
        end
      end

      context "gtag initialization withiout anonymous customer assignation" do
        before do
          customer.anonymous = false
          customer.save
          anonymous_customer = create(:customer, event: event, anonymous: true)
          @gtag = create(:gtag, event: event, customer_id: anonymous_customer.id)
        end

        it 'POST create' do
          expect do
            post :create, params: { event_id: event, gtag: { reference: @gtag.tag_uid } }
          end.to change(Gtag, :count).by(0)
        end

        it 'POST find gtag without anonymous customer' do
          post :create, params: { event_id: event, gtag: { reference: @gtag.tag_uid } }
          expect(event.gtags.last.customer.anonymous).to be(false)
        end
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
