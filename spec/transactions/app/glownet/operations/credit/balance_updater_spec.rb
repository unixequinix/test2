require "rails_helper"

RSpec.describe Operations::Credit::BalanceUpdater, type: :job do
  let(:base) { Operations::Base }
  let(:worker) { Operations::Credit::BalanceUpdater }
  let(:event) { create(:event) }
  let(:profile) { create(:profile, event: event) }
  let(:params) do
    {
      credits: 30,
      credits_refundable: 1.2,
      credit_value: 2,
      final_balance: 100,
      final_refundable_balance: 20,
      event_id: event.id,
      transaction_category: "credit",
      transaction_origin: Transaction::ORIGINS[:device],
      customer_tag_uid: "04C80D6AB63784",
      profile_id: profile.id
    }
  end

  it "updates the credits of a customer when correct values are supplied" do
    worker.perform_now(params)
    profile.reload
    expect(profile.credits.to_f).to eql(params[:credits].to_f)
  end

  it "updates the refundable credits of a customer when correct values are supplied" do
    worker.perform_now(params)
    profile.reload
    expect(profile.refundable_credits.to_f).to eql(params[:credits_refundable].to_f)
  end

  it "renames credits_refundable to refundable_credits" do
    atts = hash_including(refundable_credits: params[:credits_refundable])
    expect_any_instance_of(Profile).to receive(:update!).with(atts)
    worker.perform_now(params)
  end

  %w( topup fee refund sale sale_refund ).each_with_index do |action, _index|
    it "it is a subscriber for the action '#{action}'" do
      expect(worker).to receive(:perform_later).once
      params[:transaction_type] = action
      params[:device_created_at] = Time.zone.now.to_s
      base.perform_later(params)
    end
  end
end
