require "rails_helper"

RSpec.describe CustomerEventProfile, type: :model do
  it { is_expected.to validate_presence_of(:event) }
  let(:profile) { create(:customer_event_profile) }
  let(:atts) { { customer_event_profile: profile } }

  context "when dealing with credits" do
    describe ".online_refundable_money_amount" do
      it "returns the sum of all refundable online money from previous purchases made" do
        orders = create_list(:order_with_payment, 3, customer_event_profile: profile)
        payments = orders.map(&:payments).flatten
        amount = payments.map(&:amount).sum
        expect(amount > 0).to be_truthy
        expect(profile.online_refundable_money_amount).to eq(amount)
      end

      it "retuns 0 if no purchases are present" do
        expect(profile.online_refundable_money_amount).to eq(0)
      end
    end
  end

  it "The relation active_assignments returns the gtags and tickets assigned" do
    create(:credential_assignment_g_a, atts)
    create(:credential_assignment_g_u, atts)
    create(:credential_assignment_t_a, atts)
    create(:credential_assignment_t_u, atts)

    expect(profile.active_assignments.count).to be(2)
  end

  context "when dealing with credits, " do
    let(:credit_atts) { atts.merge(transaction_origin: "credits_purchase") }
    let(:ticket_atts) { atts.merge(transaction_origin: "ticket_assignment") }
    let(:credit_1) { create(:customer_credit_online, credit_atts) }
    let(:credit_2) { create(:customer_credit_online, credit_atts) }

    it ".total_credits returns the number of credits rounded" do
      credit_1.update_attribute :amount, 10
      credit_2.update_attribute :amount, 10
      expect(profile.total_credits).to eq(20)
    end

    describe ".refunding" do
      let(:refund) { build(:refund, amount: 20, claim: build(:claim, aasm_state: "in_progress")) }

      before do
        create_list(:customer_credit_online, 2, ticket_atts.merge(amount: 20))
        allow(profile.event).to receive(:standard_credit_price).and_return(1)
      end

      it "reduces refundable_credits_amount by the refund amount" do
        left_over = profile.refundable_credits_amount - refund.amount
        binding.pry
        profile.update_balance_after_refund(refund)
        expect(profile.reload.refundable_credits_amount).to eq(left_over)
      end

      it "reduces total_credits by the refund amount" do
        left_over = profile.total_credits - refund.amount
        profile.update_balance_after_refund(refund)
        expect(profile.reload.total_credits).to eq(left_over)
      end
    end

    describe ".ticket_credits" do
      it "returns the amount of credits rounded" do
        create_list(:customer_credit_online, 2, ticket_atts.merge(amount: 20))
        expect(profile.ticket_credits).to eq(40)
      end

      it "returns the total amount of credits" do
        create_list(:customer_credit_online, 2, ticket_atts.merge(amount: 10))
        expect(profile.ticket_credits).to eq(20)
      end

      it "returns the total amount of credits,
        only if the transaction_origin is ticket_assignment" do
        credit_1.update_attribute :amount, 1
        credit_2.update_attribute :amount, 1
        create_list(:customer_credit_online, 3, ticket_atts.merge(amount: 1))
        expect(profile.ticket_credits).to eq(3)
      end
    end

    describe "purchased_credits method" do
      it "returns the amount of credits rounded" do
        credit_1.update_attribute :amount, 1.7
        credit_2.update_attribute :amount, 2.7
        expect(profile.purchased_credits).to eq(4)
      end

      it "returns the amount of purchased credits" do
        credit_1.update_attribute :amount, 5
        credit_2.update_attribute :amount, 5
        expect(profile.purchased_credits).to eq(10)
      end

      it "returns the total amount of credits,
        only if the transaction_origin is credits_purchase" do
        credit_1.update_attribute :amount, 1
        credit_2.update_attribute :amount, 1
        create_list(:customer_credit_online, 3, ticket_atts.merge(amount: 1))
        expect(profile.purchased_credits).to eq(2)
      end
    end
  end
end
