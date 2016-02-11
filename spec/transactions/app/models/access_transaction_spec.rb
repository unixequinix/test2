require "rails_helper"

RSpec.describe AccessTransaction, type: :model do
  let(:transaction) { build(:access_transaction) }

  it "requires a type" do
    expect(transaction).to_not be_nil
  end
end
