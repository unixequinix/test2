require 'rails_helper'

RSpec.describe Admins::Events::PaymentGatewaysController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:payment_gateway) { create(:payment_gateway, event: event) }
  let(:valid_params) do
    {
      refund_field_a_name: 'iban',
      refund_field_b_name: 'swift',
      name: 'bank_account',
      fee: '0',
      minimum: '0',
      extra_fields: %w[refund_field_c_name refund_field_d_name]
    }
  end

  before(:each) { sign_in user }

  describe "GET #index" do
    context "bank_account" do
      it "returns a success response" do
        get :index, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET #new" do
    context "bank_account" do
      it "returns a success response" do
        get :new, params: { event_id: event.id, name: payment_gateway.name }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST #create" do
    context("valid parameters") do
      context "bank_account" do
        it "redirect to payments gateway path" do
          post :create, params: { event_id: event.id, name: 'bank_account_1', payment_gateway: valid_params }
          expect(response).to redirect_to(admins_event_payment_gateways_path(event))
        end

        it "should trigger flash notice" do
          post :create, params: { event_id: event.id, name: 'bank_account_1', payment_gateway: valid_params }
          expect(flash[:notice]).to be_present
        end

        it "should have data parameter" do
          post :create, params: { event_id: event.id, name: 'bank_account_2', payment_gateway: valid_params }
          expect(PaymentGateway.last.data).not_to be_empty
        end
      end
    end

    context("invalid parameters") do
      context "bank_account" do
        it "should trigger flash error" do
          post :create, params: { event_id: event.id, payment_gateway: { name: payment_gateway.name } }
          expect(flash[:alert]).to be_present
        end
      end
    end
  end

  describe "GET #edit" do
    context "bank_account" do
      it "returns a success response" do
        get :edit, params: { event_id: event.id, id: payment_gateway.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PUT #update" do
    context("valid parameters") do
      context "bank_account" do
        before(:each) do
          payment_gateway.data = valid_params
          payment_gateway.save!
        end

        it "redirect to payments gateway path" do
          put :update, params: { event_id: event.id, id: payment_gateway.id, payment_gateway: valid_params }
          expect(response).to redirect_to(admins_event_payment_gateways_path(event))
        end

        it "should trigger flash notice" do
          put :update, params: { event_id: event.id, id: payment_gateway.id, payment_gateway: valid_params }
          expect(flash[:notice]).to be_present
        end

        it "should have data parameter" do
          put :update, params: { event_id: event.id, id: payment_gateway.id, payment_gateway: valid_params }
          expect(PaymentGateway.last.data).not_to be_empty
        end
      end
    end
  end
end
