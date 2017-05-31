require "spec_helper"

RSpec.describe Transactions::Operator::PermissionCreator, type: :job do
  let(:base) { Transactions::Base }
  let(:worker) { Transactions::Operator::PermissionCreator }
  let(:event) { create(:event) }
  let(:params) do
    { gtag_id: create(:gtag, event: event).id,
      event_id: event.id,
      role: "operator",
      action: "record_operator_permission",
      device_created_at: Time.zone.now.to_formatted_s(:transactions) }
  end

  it "creates an operator_permission with group" do
    params[:group] = "banking"
    expect { base.perform_later(params) }.to change(event.operator_permissions, :count).by(1)
  end

  it "creates an operator_permission with station" do
    station = create(:station, event: event)
    params[:station_permission_id] = station.station_event_id
    expect { base.perform_later(params) }.to change(event.operator_permissions, :count).by(1)
  end

  it "assigns the permission with the transaction" do
    params[:group] = "banking"
    base.perform_later(params)
    expect(event.transactions.where(catalog_item_id: event.operator_permissions.first.id))
  end

  %w[record_operator_permission].each do |action|
    it "it is a subscriber for the action '#{action}'" do
      expect(worker).to receive(:perform_later).once
      params[:action] = action
      params[:device_created_at] = Time.zone.now.to_s
      base.perform_later(params)
    end
  end
end
