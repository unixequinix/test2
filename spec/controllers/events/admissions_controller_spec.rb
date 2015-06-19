require 'rails_helper'

RSpec.describe Events::AdmissionsController, type: :controller do
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @event = create(:event)
  end

  describe 'CREATE' do
    let(:post_params) do
      { admission: attributes_for(:customer).merge(event_id: @event.id),
        event_id: @event.id,  }
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

    it "associates the customer with the admission" do
      post :create, post_params
      customer = Customer.last
      admission = Admission.last
      expect(admission.customer).to eq(customer)
    end
  end
end
