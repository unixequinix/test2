require 'rails_helper'

RSpec.describe Events::AdmissionsController, type: :controller do
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @event = create(:event)
  end

  describe 'CREATE' do
    context 'with valid params' do
      let(:post_params) do
        customer_attributes = attributes_for(:customer)
        customer_attributes[:agreed_on_registration] = '1'
        { admission: customer_attributes, event_id: @event.id  }
      end

      it 'creates a customer' do
        expect do
          post :create, post_params
        end.to change(Customer, :count).by(1)
      end

      it 'creates an admission' do
        expect do
          post :create, post_params
        end.to change(Admission, :count).by(1)
      end

      it 'associates the customer with the admission' do
        post :create, post_params
        customer = Customer.last
        admission = Admission.last
        expect(admission.customer).to eq(customer)
      end
    end

    # context 'with invalid params' do
    #   let(:post_params) do
    #     { admission: attributes_for(:customer).merge(event_id: @event.id),
    #       event_id: @event.id  }
    #   end

    #   it 'does not create an admission' do
    #     expect do
    #       post :create, post_params
    #     end.not_to change(Admission, :count)
    #   end
    # end
  end
end
