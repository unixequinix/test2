require 'rails_helper'

RSpec.describe CredentialTransaction, type: :model do
  let(:transaction) { build(:credential_transaction) }

  it "requires a type" do
    expect(transaction).to_not be_nil
  end
end
