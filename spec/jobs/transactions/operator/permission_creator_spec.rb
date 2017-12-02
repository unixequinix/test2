require "rails_helper"

RSpec.describe Transactions::Operator::PermissionCreator, type: :job do
  let(:worker) { Transactions::Operator::PermissionCreator.new }
  let(:event) { create(:event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:transaction) { create(:operator_transaction, event: event, action: "record_operator_permission") }
  let(:atts) { { gtag_id: gtag.id, role: "operator", action: transaction.action } }

  it "creates an operator_permission with group" do
    atts[:group] = "banking"
    expect { worker.perform(transaction, atts) }.to change { event.reload.operator_permissions.count }.by(1)
  end

  it "creates an operator_permission with station" do
    atts[:station_permission_id] = create(:station, event: event).station_event_id
    expect { worker.perform(transaction, atts) }.to change(event.operator_permissions, :count).by(1)
  end

  it "assigns the permission to the transaction" do
    atts[:group] = "banking"
    worker.perform(transaction, atts)
    expect(event.transactions.where(catalog_item_id: event.operator_permissions.first.id)).to eq(event.transactions.where(id: transaction.id))
  end
end
