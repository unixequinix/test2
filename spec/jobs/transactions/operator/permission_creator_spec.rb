require "rails_helper"

RSpec.describe Transactions::Operator::PermissionCreator, type: :job do
  let(:worker) { Transactions::Operator::PermissionCreator.new }
  let(:event) { create(:event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:transaction) { create(:credential_transaction, event: event, action: "record_operator_permission") }
  let(:params) { { gtag_id: gtag.id, event_id: event.id, role: "operator", action: transaction.action, transaction_id: transaction.id } }

  it "creates an operator_permission with group" do
    params[:group] = "banking"
    expect { worker.perform(params) }.to change { event.reload.operator_permissions.count }.by(1)
  end

  it "creates an operator_permission with station" do
    params[:station_permission_id] = create(:station, event: event).station_event_id
    expect { worker.perform(params) }.to change(event.operator_permissions, :count).by(1)
  end

  it "assigns the permission to the transaction" do
    params[:group] = "banking"
    worker.perform(params)
    expect(event.transactions.where(catalog_item_id: event.operator_permissions.first.id)).to eq(event.transactions.where(id: transaction.id))
  end
end
