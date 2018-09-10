require 'rails_helper'

RSpec.describe Events::SessionsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer_unconfirmed) { create(:customer_unconfirmed, event: event) }
  let(:customer) { create(:customer, event: event) }

  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:customer]
  end

  describe 'GET show' do
    context 'customer exists and confirmed' do
      it 'GET show when customer is confirmed' do
        customer_unconfirmed.confirm do
          expect(response).to be_ok
        end
      end

      it 'GET show redirection when customer is confirmed' do
        customer_unconfirmed.confirm do
          expect(response).to redirect_to(event_login_path(event))
        end
      end

      it 'GET show when customer is signed_in' do
        sign_in customer

        customer.confirm do
          expect(response).to redirect_to(customer_root_path(confirmed_customer))
        end
      end
    end

    context 'customer does not exist' do
      it 'GET show when customer is confirmed' do
        customer_unconfirmed.confirm do
          expect(response).to be_ok
        end
      end

      it 'GET show when customer is confirmed' do
        customer_unconfirmed.confirm do
          expect(response).to redirect_to(event_login_path(event))
        end
      end
    end
  end
end
