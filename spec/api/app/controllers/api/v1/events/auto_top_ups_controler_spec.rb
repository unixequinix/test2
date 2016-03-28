require "rails_helper"

RSpec.describe Api::V1::Events::AutoTopUpsController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { Admin.first || create(:admin) }
  let(:params) do
    { auto_top_up: { gtag_uid: "ASD23ASD23ASD", payment_method: %w(paypal braintree).sample } }
  end

  let(:invalid_params) do
    { auto_top_up: { uid: "ASD23ASD23ASD", method: "paypal" } }
  end

  describe "POST create" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      context "when the params exists" do
        context "when the request is valid" do
          before(:each) do
            post :create, event_id: event.id, auto_top_up: params
          end

          it "increases the payments in the database by 1" do
            expect do
              post :create, event_id: event.id, auto_top_up: params
            end.to change(Payment, :count).by(1)
          end

          it "returns a 201 status code" do
            expect(response.status).to eq(201)
          end

          it "returns the customer_id and the amout" do
            body = JSON.parse(response.body)
            expect(body).to include("customer_id", "amount")
          end
        end

        context "when the request is invalid" do
          it "returns a 422 status code" do
            expect(response.status).to eq(422)
          end
        end
      end

      context "when params doesn't exists" do
        it "returns a 400 status code" do
          post :create, event_id: event.id, auto_top_up: invalid_params
          expect(response.status).to eq(400)
        end
      end
    end

    context "without authentication" do
      it "has a 401 status code" do
        post :create, event_id: event.id
        expect(response.status).to eq(401)
      end
    end
  end
end
