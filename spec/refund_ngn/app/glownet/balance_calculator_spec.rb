require "rails_helper"

RSpec.describe BalanceCalculator, type: :domain_logic do
  describe "It performs the needed operations about balances" do
    let(:customer_event_profile) do
      create(:customer_event_profile)
    end

    let(:balance_calculator) { BalanceCalculator.new(customer_event_profile) }

    it ".total_credits_amount returns 0 if the customer hasn't got credits" do
      expect(balance_calculator.total_credits_amount).to eq(0)
    end

    it ".total_credits_amount returns the current amount of credits that belongs to a customer" do
      create(:customer_credit_online, customer_event_profile: customer_event_profile)
      expect(balance_calculator.total_credits_amount).to eq(20)
    end

    it ".valid_balance? returns true if the balance is valid after the event" do
      create(:customer_credit_online, customer_event_profile: customer_event_profile)
      expect(balance_calculator.valid_balance?).to eq(true)
    end
  end
end
