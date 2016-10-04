require "rails_helper"

RSpec.describe Profile, type: :model do
  it { is_expected.to validate_presence_of(:event) }
  let(:profile) { create(:profile) }

  describe ".online_refundable_money" do
    context "when profile has orders" do
      it "returns the sum of all online refundable money" do
        orders = create_list(:order_with_direct_payment, 3, :with_different_items, profile: profile)
        amount = orders.map(&:payments).flatten.map(&:amount).sum
        expect(profile.online_refundable_money).to eq(amount)
      end
    end

    context "when profile doesn't have online orders" do
      it "retuns 0" do
        expect(profile.online_refundable_money).to eq(0)
      end
    end
  end

  describe ".recalculate_balance" do
    context "with multiple online transactions for one purchase" do
      before do
        @transaction = create(:credit_transaction, profile: profile, transaction_type: "online_topup", credits: 10, refundable_credits: 5, credit_value: 1, final_balance: 10, final_refundable_balance: 5)
        @transaction = create(:credit_transaction, profile: profile, transaction_type: "online_topup", credits: 30, refundable_credits: 30, credit_value: 1, final_balance: 30, final_refundable_balance: 30)
      end

      it "recalculates the balance properly" do
        profile.recalculate_balance
        profile.reload
        expect(profile.credits).to eq(40)
        expect(profile.refundable_credits).to eq(35)
        expect(profile.final_balance).to eq(40)
        expect(profile.final_refundable_balance).to eq(35)
      end
    end

    context "with record credit being last" do
      before do
        @online_topup = create(:credit_transaction, profile: profile, transaction_type: "online_topup", credits: 10, refundable_credits: 5, credit_value: 1, final_balance: 10, final_refundable_balance: 5)
        @onsite_topup = create(:credit_transaction, profile: profile, transaction_type: "topup", credits: 15, refundable_credits: 15, credit_value: 1, final_balance: 15, final_refundable_balance: 15, gtag_counter: 1)
        @record_credit = create(:credit_transaction, profile: profile, transaction_type: "record_credit", credits: 10, refundable_credits: 5, credit_value: 1, final_balance: 25, final_refundable_balance: 20, gtag_counter: 2)
      end

      it "recalculates the balance properly" do
        profile.recalculate_balance
        profile.reload
        expect(profile.credits).to eq(25)
        expect(profile.refundable_credits).to eq(20)
        expect(profile.final_balance).to eq(25)
        expect(profile.final_refundable_balance).to eq(20)
      end
    end
  end
end
