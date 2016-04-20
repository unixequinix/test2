require "rails_helper"

RSpec.describe Api::V1::Events::AutoTopUpsController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:cep) { create(:customer_event_profile, event: event) }
  let(:ca) { create(:credential_assignment_g_a, customer_event_profile: cep) }
  let(:tag_uid) { ca.credentiable.tag_uid }
  let(:params) do
    { event_id: event.id, gtag_uid: tag_uid, payment_method: "paypal", "order_id": "16032918b57e" }
  end
  let(:invalid_params) { { event_id: event.id, uid: "error", method: "error" } }

  describe "POST create" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      context "when the params exists" do
        context "when the request is valid" do
          context "when the agreement is signed" do
            it "returns a 201 status code" do
              res = { gtag_uid: tag_uid, credit_amount: 20, money_amount: 40, credit_value: 1 }
              allow(Autotopup::PaypalAutoPayer).to receive(:start).and_return(res)
              post :create, params
              body = JSON.parse(response.body)
              expect(response.status).to eq(201)
              expect(body).to include("gtag_uid", "credit_amount", "money_amount", "credit_value")
            end
          end

          context "when the agreement is not signed" do
            it "returns a 422 status code" do
              post :create, params
              expect(response.status).to eq(422)
            end
          end
        end

        context "when the request fails" do
          it "returns a 422 status code" do
            post :create, params
            expect(response.status).to eq(422)
          end
        end
      end

      context "when params doesn't exists" do
        it "returns a 400 status code" do
          post :create, invalid_params
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
