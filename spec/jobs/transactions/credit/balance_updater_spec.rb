require "spec_helper"

RSpec.describe Transactions::Credit::BalanceUpdater, type: :job do
  let(:base) { Transactions::Base }
  let(:worker) { Transactions::Credit::BalanceUpdater }
  let(:event) { create(:event) }
  let(:params) { { gtag_id: create(:gtag, event: event).id, event_id: event.id } }

  it "calls recalculate_balance on the given customer" do
    expect_any_instance_of(Gtag).to receive(:recalculate_balance)
    worker.perform_now(params)
  end

  %w(sale topup refund fee sale_refund record_credit).each do |action|
    it "it is a subscriber for the action '#{action}'" do
      expect(worker).to receive(:perform_later).once
      params[:action] = action
      params[:device_created_at] = Time.zone.now.to_s
      base.perform_later(params)
    end
  end
end
