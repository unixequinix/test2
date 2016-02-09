require 'rails_helper'

RSpec.describe MonetaryTransaction, type: :model do
  let(:transaction) { build(:monetary_transaction) }

  it "expects to define methods for each subscription action" do
    transaction.class::SUBSCRIPTIONS.values.flatten.each do |action|
      expect(transaction).to respond_to(action)
    end
  end
end
