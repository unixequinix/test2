require "rails_helper"

RSpec.describe Api::V1::Events::AutoTopUpsController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { Admin.first || create(:admin) }
  let(:cep) { create(:customer_event_profile, event: event) }
  let(:ca) { create(:credential_assignment_g_a, customer_event_profile: cep) }
  let(:tag_uid) { ca.credentiable.tag_uid }
  let(:payer) { Autotopup::PaypalAutoPayer.new(cep) }
  let(:params) { { gtag_uid: tag_uid, payment_method: %w(paypal).sample } }
  let(:invalid_params) { { uid: "error", method: "error" } }

  describe "POST create" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      context "when the params exists" do
        context "when the request is valid" do
          context "when the agreement is signed" do
            before(:each) do
              expect(payer).to receive(:start).and_return(nil)
              post :create, event_id: event.id, auto_top_up: params
            end

            it "returns a 201 status code" do
              expect(response.status).to eq(201)
            end

            it "returns the customer_id and the amout" do
              body = JSON.parse(response.body)
              expect(body).to include("customer_id", "amount")
            end
          end

          context "when the agreement is not signed" do
            before(:each) do
              post :create, event_id: event.id, auto_top_up: params
            end

            it "returns a 422 status code" do
              expect(response.status).to eq(422)
            end
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
